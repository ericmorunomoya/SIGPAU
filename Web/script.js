// Efecto de aparición en scroll para elementos con la clase 'animate__animated'
const animateElements = document.querySelectorAll('.animate__animated');

const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            // Para animaciones que solo deben ocurrir una vez
            if (entry.target.classList.contains('animate__animated')) {
                entry.target.classList.add(entry.target.dataset.animation);
            }
        } else {
            // Opcional: remover 'visible' si se quiere que la animación se repita al hacer scroll hacia arriba
            // entry.target.classList.remove('visible');
            // if (entry.target.classList.contains('animate__animated')) {
            //     entry.target.classList.remove(entry.target.dataset.animation);
            // }
        }
    });
}, { threshold: 0.1 }); // El 10% del elemento debe ser visible

animateElements.forEach(el => {
    // Obtener la clase de animación de un atributo de datos, si existe
    const animationClass = el.classList.value.split(' ').find(cls => cls.startsWith('animate__'));
    if (animationClass) {
        el.dataset.animation = animationClass;
        el.classList.remove(animationClass);
    }
    observer.observe(el);
});

// Efecto Parallax mejorado en scroll
window.addEventListener('scroll', () => {
    const parallaxElements = document.querySelectorAll('.parallax');
    parallaxElements.forEach(parallax => {
        const scrolled = window.pageYOffset;
        // Ajusta el factor para un efecto más o menos pronunciado
        parallax.style.transform = `translateY(${scrolled * 0.4}px)`;
    });

    // Cambiar color de la navbar al hacer scroll
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.backgroundColor = 'rgba(0, 0, 0, 0.95)'; // Más oscuro al hacer scroll
    } else {
        navbar.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
    }
});

// Smooth scroll para anchors
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const targetId = this.getAttribute('href');
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            window.scrollTo({
                top: targetElement.offsetTop - document.querySelector('.navbar').offsetHeight, // Ajustar por la altura de la navbar
                behavior: 'smooth'
            });
        }
    });
});

// Efecto de escritura en el hero (opcional, si se desea un texto dinámico)
// function typeWriter(element, text, delay = 100) {
//     let i = 0;
//     element.innerHTML = '';
//     const interval = setInterval(() => {
//         if (i < text.length) {
//             element.innerHTML += text.charAt(i);
//             i++;
//         } else {
//             clearInterval(interval);
//         }
//     }, delay);
// }

// const heroLead = document.querySelector('.hero p.lead');
// if (heroLead) {
//     const originalText = heroLead.textContent;
//     heroLead.textContent = ''; // Limpiar el texto original
//     setTimeout(() => {
//         typeWriter(heroLead, originalText);
//     }, 2000); // Retraso para que empiece después de otras animaciones
// }

// Inicializar animaciones al cargar la página
document.addEventListener('DOMContentLoaded', () => {
    // Activar animaciones iniciales si están en el viewport
    animateElements.forEach(el => {
        const rect = el.getBoundingClientRect();
        if (rect.top < window.innerHeight && rect.bottom > 0) {
            el.classList.add('visible');
            if (el.classList.contains('animate__animated')) {
                el.classList.add(el.dataset.animation);
            }
        }
    });
});

