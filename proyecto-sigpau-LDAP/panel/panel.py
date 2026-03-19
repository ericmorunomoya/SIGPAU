#!/usr/bin/env python3
"""
SIGPAU Control Center - Backend
Servidor Flask para monitorización de la infraestructura SIGPAU
"""
from flask import Flask, jsonify, render_template, Response
import subprocess
import datetime
import json
import os
import re

app = Flask(__name__)

# ─── Config ──────────────────────────────────────────────────────────────────
DB_HOST = "10.120.22.207"
DB_USER = "admin01"
DB_PASS = "Sigpau2026*"
DB_NAME = "sigpau_mgmt"

# ─── Helper: run shell command ────────────────────────────────────────────────
def run(cmd, default="N/A"):
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=8)
        return result.stdout.strip() or default
    except Exception:
        return default

def run_ssh(ip, passwd, cmd, default="N/A"):
    ssh_cmd = f"sshpass -p '{passwd}' ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 root@{ip} \"{cmd}\""
    return run(ssh_cmd, default)

# ─── API: Estado SSSD ─────────────────────────────────────────────────────────
@app.route("/api/sssd")
def api_sssd():
    domains = {}
    for domain in ["sigpau.lab", "sigpau.local"]:
        # SSSD corre en el Cliente Debian (10.120.17.247)
        out = run_ssh("10.120.17.247", "Asdqwe123", f"sssctl domain-status {domain} 2>&1")
        online = "Online" in out and "Offline" not in out
        domains[domain] = {"online": online, "raw": out}
    return jsonify(domains)

# ─── API: Usuarios en sesión ──────────────────────────────────────────────────
@app.route("/api/users")
def api_users():
    # Who en el cliente Debian (donde se loguean los usuarios LDAP)
    who_out = run_ssh("10.120.17.247", "Asdqwe123", "who")
    users = []
    for line in who_out.splitlines():
        parts = line.split()
        if len(parts) >= 3:
            users.append({
                "user": parts[0],
                "tty": parts[1],
                "time": " ".join(parts[2:4]) if len(parts) >= 4 else parts[2]
            })
    # Total en Samba AD
    total_ldap = run("samba-tool user list 2>/dev/null | wc -l || getent passwd | wc -l")
    return jsonify({"active_sessions": users, "total_domain_users": total_ldap.strip()})

# ─── API: Estado RAID ─────────────────────────────────────────────────────────
@app.route("/api/raid")
def api_raid():
    # El RAID está en el NAS (10.1.100.17)
    mdstat = run_ssh("10.1.100.17", "Asdqwe123456789.", "cat /proc/mdstat 2>/dev/null || echo 'No RAID'")
    detail = run_ssh("10.1.100.17", "Asdqwe123456789.", "mdadm --detail /dev/md0 2>&1 | grep -E 'State|Active|Degraded|Rebuild|UUID' | head -6")
    espacio = run_ssh("10.1.100.17", "Asdqwe123456789.", "df -h /home 2>/dev/null | tail -1")
    # Parse estado
    estado = "Activo"
    if "degraded" in mdstat.lower():
        estado = "Degradado"
    elif "No RAID" in mdstat or "cannot" in detail.lower():
        estado = "Sin datos"
    return jsonify({"estado": estado, "mdstat": mdstat[:500], "detail": detail, "espacio": espacio})

# ─── API: Backups (MariaDB) ───────────────────────────────────────────────────
@app.route("/api/backups")
def api_backups():
    try:
        import mysql.connector
        conn = mysql.connector.connect(
            host=DB_HOST, user=DB_USER, password=DB_PASS,
            database=DB_NAME, connect_timeout=5
        )
        cur = conn.cursor(dictionary=True)
        cur.execute("SELECT fecha, archivo, destino, estado FROM backup_logs ORDER BY fecha DESC LIMIT 10")
        rows = cur.fetchall()
        conn.close()
        # Serializar fechas
        for r in rows:
            r["fecha"] = str(r["fecha"])
        return jsonify({"status": "ok", "backups": rows})
    except Exception as e:
        return jsonify({"status": "error", "backups": [], "error": str(e)})

# ─── API: Info general del sistema ────────────────────────────────────────────
@app.route("/api/system")
def api_system():
    hostname = run("hostname -f")
    uptime = run("uptime -p")
    ip_ad = run("ip -4 addr show | grep 'inet 10' | awk '{print $2}' | head -3")
    samba = run("systemctl is-active samba-ad-dc 2>/dev/null || systemctl is-active samba 2>/dev/null || systemctl is-active smbd 2>/dev/null")
    kerberos_ticket = run("klist -k 2>&1 | grep 'Default principal' || echo 'Sin ticket'")
    ldap_port = run("ss -tlnp | grep ':389 ' | awk '{print $4}'")
    return jsonify({
        "hostname": hostname,
        "uptime": uptime,
        "ips": ip_ad,
        "samba_status": samba.strip(),
        "kerberos": kerberos_ticket,
        "ldap_port": ldap_port or "389"
    })

# ─── API: Generar informe HTML ────────────────────────────────────────────────
@app.route("/api/informe")
def api_informe():
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Recopilar datos
    sys_data = json.loads(api_system().data)
    sssd_data = json.loads(api_sssd().data)
    users_data = json.loads(api_users().data)
    raid_data = json.loads(api_raid().data)
    backup_data = json.loads(api_backups().data)

    # Build rows backup
    backup_rows = ""
    for b in backup_data.get("backups", []):
        color = "#27ae60" if b.get("estado") == "EXITOSO" else "#e74c3c"
        backup_rows += f"<tr><td>{b['fecha']}</td><td>{b['archivo']}</td><td>{b['destino']}</td><td style='color:{color};font-weight:bold'>{b['estado']}</td></tr>"
    if not backup_rows:
        backup_rows = "<tr><td colspan='4' style='text-align:center;color:#999'>Sin datos de backup disponibles</td></tr>"

    # Sessions
    session_rows = "".join(
        f"<tr><td>{u['user']}</td><td>{u['tty']}</td><td>{u['time']}</td></tr>"
        for u in users_data.get("active_sessions", [])
    ) or "<tr><td colspan='3' style='text-align:center;color:#999'>Sin sesiones activas</td></tr>"

    # SSSD states
    sssd_rows = ""
    for dom, info in sssd_data.items():
        estado = "🟢 Online" if info["online"] else "🔴 Offline"
        sssd_rows += f"<tr><td>{dom}</td><td>{estado}</td></tr>"

    html = f"""<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Informe SIGPAU - {now}</title>
<style>
  body {{ font-family: 'Segoe UI', sans-serif; background: #f0f4f8; color: #2d3748; margin: 0; padding: 30px; }}
  .header {{ background: linear-gradient(135deg, #1a1a2e, #16213e); color: white; padding: 30px 40px; border-radius: 12px; margin-bottom: 30px; box-shadow: 0 4px 20px rgba(0,0,0,0.3); }}
  .header h1 {{ margin: 0; font-size: 2em; letter-spacing: 2px; }}
  .header p {{ margin: 8px 0 0; opacity: 0.7; font-size: 0.9em; }}
  .badge {{ display: inline-block; padding: 4px 12px; border-radius: 20px; background: #a78bfa; color: white; font-size: 0.75em; margin-left: 10px; vertical-align: middle; }}
  .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }}
  .card {{ background: white; border-radius: 10px; padding: 25px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }}
  .card h2 {{ margin: 0 0 15px; font-size: 1em; color: #7c3aed; text-transform: uppercase; letter-spacing: 1px; border-bottom: 2px solid #ede9fe; padding-bottom: 10px; }}
  .kv {{ display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #f3f4f6; font-size: 0.88em; }}
  .kv:last-child {{ border-bottom: none; }}
  .kv label {{ color: #6b7280; font-weight: 600; }}
  table {{ width: 100%; border-collapse: collapse; font-size: 0.85em; }}
  th {{ background: #7c3aed; color: white; padding: 10px 12px; text-align: left; }}
  td {{ padding: 9px 12px; border-bottom: 1px solid #f3f4f6; }}
  tr:last-child td {{ border-bottom: none; }}
  .footer {{ text-align: center; color: #9ca3af; font-size: 0.8em; margin-top: 30px; }}
  .status-ok {{ color: #27ae60; font-weight: bold; }}
  .status-err {{ color: #e74c3c; font-weight: bold; }}
  @media print {{ body {{ background: white; padding: 10px; }} .card {{ box-shadow: none; border: 1px solid #e5e7eb; }} }}
</style>
</head>
<body>
<div class="header">
  <h1>🛡️ SIGPAU Control Center <span class="badge">Informe Automático</span></h1>
  <p>Generado: {now} &nbsp;|&nbsp; Host: {sys_data.get('hostname','N/A')} &nbsp;|&nbsp; Uptime: {sys_data.get('uptime','N/A')}</p>
</div>

<div class="grid">
  <div class="card">
    <h2>🖥️ Sistema</h2>
    <div class="kv"><label>Hostname</label><span>{sys_data.get('hostname','N/A')}</span></div>
    <div class="kv"><label>IPs</label><span>{sys_data.get('ips','N/A')}</span></div>
    <div class="kv"><label>Uptime</label><span>{sys_data.get('uptime','N/A')}</span></div>
    <div class="kv"><label>Samba AD</label><span class="{'status-ok' if sys_data.get('samba_status')=='active' else 'status-err'}">{sys_data.get('samba_status','N/A').upper()}</span></div>
    <div class="kv"><label>Puerto LDAP</label><span>{sys_data.get('ldap_port','389')}</span></div>
    <div class="kv"><label>Kerberos</label><span>{sys_data.get('kerberos','N/A')}</span></div>
  </div>

  <div class="card">
    <h2>🔐 Autenticación SSSD</h2>
    <table>
      <tr><th>Dominio</th><th>Estado</th></tr>
      {sssd_rows}
    </table>
  </div>

  <div class="card">
    <h2>💾 RAID 5 NAS</h2>
    <div class="kv"><label>Estado</label><span class="{'status-ok' if raid_data.get('estado')=='Activo' else 'status-err'}">{raid_data.get('estado','N/A')}</span></div>
    <div class="kv"><label>Espacio /home</label><span>{raid_data.get('espacio','N/A')}</span></div>
    <pre style="background:#f9f9f9;padding:10px;border-radius:6px;font-size:0.75em;overflow:auto;max-height:120px">{raid_data.get('mdstat','N/A')[:300]}</pre>
  </div>
</div>

<div class="card" style="margin-bottom:20px">
  <h2>👥 Sesiones Activas</h2>
  <table>
    <tr><th>Usuario</th><th>Terminal</th><th>Desde</th></tr>
    {session_rows}
  </table>
</div>

<div class="card">
  <h2>📦 Histórico de Backups</h2>
  <table>
    <tr><th>Fecha</th><th>Archivo</th><th>Destino</th><th>Estado</th></tr>
    {backup_rows}
  </table>
</div>

<div class="footer">
  <p>🎓 Proyecto SIGPAU — ASIX2 | Generado automáticamente por SIGPAU Control Center</p>
  <p>Para imprimir: Ctrl+P → "Guardar como PDF"</p>
</div>
</body>
</html>"""
    
    return Response(
        html,
        mimetype="text/html",
        headers={"Content-Disposition": f"attachment;filename=informe_sigpau_{datetime.datetime.now().strftime('%Y%m%d_%H%M')}.html"}
    )

# ─── Página principal ─────────────────────────────────────────────────────────
@app.route("/")
def index():
    return render_template("index.html")

if __name__ == "__main__":
    print("🚀 SIGPAU Control Center arrancando en http://0.0.0.0:8080")
    app.run(host="0.0.0.0", port=8080, debug=False)
