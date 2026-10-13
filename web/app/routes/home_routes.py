from flask import Blueprint, render_template

home_bp = Blueprint('home', __name__)

@home_bp.route('/')
def index():
    features = [
        {
            'icon': '📊',
            'title': 'Burnout Assessment',
            'desc': 'Evaluasi tingkat stres dan burnout kerja secara berkala menggunakan indikator ilmiah yang valid.'
        },
        {
            'icon': '💡',
            'title': 'Rekomendasi Pintar',
            'desc': 'Dapatkan saran pemulihan terpersonalisasi, panduan micro-break, dan strategi batas kerja sehat.'
        },
        {
            'icon': '📈',
            'title': 'Pemantauan Berkala',
            'desc': 'Pantau tren kesehatan mental dan tingkat energimu dari waktu ke waktu sebelum kelelahan kronis terjadi.'
        }
    ]
    return render_template('home/index.html', title='AntiBurnout - Keseimbangan Kerja Sehat', features=features)

@home_bp.route('/about')
def about():
    return render_template('home/about.html', title='Tentang AntiBurnout')
