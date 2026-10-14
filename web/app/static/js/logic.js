// AntiBurnout - Client-side interactivity

document.addEventListener('DOMContentLoaded', () => {
  // Mobile Nav Toggle
  const navToggle = document.getElementById('navToggle');
  const navMenu = document.getElementById('navMenu');

  if (navToggle && navMenu) {
    navToggle.addEventListener('click', () => {
      navMenu.classList.toggle('show');
    });
  }

  // Auto-dismiss or manual close for alerts
  const alertCloseButtons = document.querySelectorAll('.alert-close');
  alertCloseButtons.forEach((btn) => {
    btn.addEventListener('click', () => {
      const alert = btn.closest('.alert');
      if (alert) {
        alert.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        alert.style.opacity = '0';
        alert.style.transform = 'translateY(-10px)';
        setTimeout(() => alert.remove(), 300);
      }
    });
  });

  // Auto-dismiss alert after 5 seconds
  const alerts = document.querySelectorAll('.alert');
  if (alerts.length > 0) {
    setTimeout(() => {
      alerts.forEach((alert) => {
        alert.style.transition = 'opacity 0.4s ease, transform 0.4s ease';
        alert.style.opacity = '0';
        setTimeout(() => alert.remove(), 400);
      });
    }, 5000);
  }
});
