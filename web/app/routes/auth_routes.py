from flask import Blueprint, render_template, request, redirect, url_for, flash

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')

        if not email or not password:
            flash('Harap lengkapi email dan kata sandi.', 'danger')
        else:
            flash(f'Selamat datang kembali, {email}!', 'success')
            return redirect(url_for('home.index'))

    return render_template('auth/login.html', title='Masuk ke Akun - AntiBurnout')

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form.get('name', '').strip()
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        confirm_password = request.form.get('confirm_password', '')

        if not name or not email or not password:
            flash('Semua kolom formulir wajib diisi.', 'danger')
        elif password != confirm_password:
            flash('Konfirmasi kata sandi tidak cocok.', 'danger')
        else:
            flash('Pendaftaran akun berhasil! Silakan masuk.', 'success')
            return redirect(url_for('auth.login'))

    return render_template('auth/register.html', title='Daftar Akun Baru - AntiBurnout')
