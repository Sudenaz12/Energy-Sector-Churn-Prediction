import joblib
import numpy as np
import pandas as pd
from sqlalchemy import create_engine

# 1. SQL Server Bağlantısı
sunucu = 'DESKTOP-6KLDFGH\\SQLEXPRESS01'
veritabani = 'VeriProje'
baglanti_metni = f'mssql+pyodbc://@{sunucu}/{veritabani}?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes'
engine = create_engine(baglanti_metni)

# 2. Model ve Şablon Yükleme
xgb_model = joblib.load('xgb_churn_model.pkl')
model_sutunlari = joblib.load('model_sutunlari.pkl')

# 3.Test Müşterilerini Çekme Sorgusu
query = """
SELECT * FROM vw_Final_Churn_Analizi 
WHERE Musteri_ID IN ('TEST_9901', 'TEST_9902', 'TEST_9903', 'TEST_9904','TEST_9905','TEST_9906','NEW_CLIENT_001','NEW_CLIENT_002','NEW_CLIENT_003','NEW_CLIENT_004')
"""
df_canli = pd.read_sql(query, engine)

rapor_bilgileri = df_canli[['Musteri_ID', 'Satis_Kanali', 'Kampanya_Tipi', 'Net_Kar_Marji']].copy()
df_canli.set_index('Musteri_ID', inplace=True)

# 4. Veri Ön İşleme ve Özellik Mühendisliği
df_canli['Baslangic_Tarihi'] = pd.to_datetime(df_canli['Baslangic_Tarihi'], format='%d.%m.%Y')
df_canli['Bitis_Tarihi'] = pd.to_datetime(df_canli['Bitis_Tarihi'], format='%d.%m.%Y')
df_canli['Sozlesme_Suresi_Gun'] = (df_canli['Bitis_Tarihi'] - df_canli['Baslangic_Tarihi']).dt.days

toplam_tuketim = (df_canli['Gaz_Tuketimi_12Ay'] + df_canli['Elektrik_Tuketimi_12Ay'])
df_canli['Birim_Başina_kar'] = np.where(toplam_tuketim == 0, 0, df_canli['Net_Kar_Marji'] / toplam_tuketim)
df_canli['Tahmini_sapmasi'] = np.where(
    df_canli['Tahmini_Tuketim_12Ay'] == 0, 0, 
    df_canli['Elektrik_Tuketimi_12Ay'] / df_canli['Tahmini_Tuketim_12Ay']
)

df_canli['Indirim_Segmenti'] = df_canli['Indirim_Segmenti'].str.split('-').str[0].astype(int)
df_canli['Musteri_Profil_Segmenti'] = df_canli['Musteri_Profil_Segmenti'].str.split('-').str[0].astype(int)
df_canli['Musteri_Kapasite_Segmenti'] = df_canli['Musteri_Kapasite_Segmenti'].str.split('-').str[0].astype(int)

df_canli.drop(
    ['Baslangic_Tarihi', 'Bitis_Tarihi', 'Kaynak_Kampanya', 'Churn_Durumu', 'Fiyat_Dalgalanma_Orani'],
    axis=1, inplace=True, errors='ignore'
)

# 5. One-Hot Encoding ve Hizalama
df_encoded = pd.get_dummies(df_canli, columns=['Satis_Kanali', 'Kampanya_Tipi'], drop_first=False)
df_encoded = df_encoded.astype(float)
x_test_canli = df_encoded.reindex(columns=model_sutunlari, fill_value=0.0)

# 6. Tahmin Üretme
olasiliklar = xgb_model.predict_proba(x_test_canli)[:, 1]

rapor_bilgileri['Ayrılma İhtimali'] = [f'%{p*100:.2f}' for p in olasiliklar]
rapor_bilgileri['Model Kararı (0.38 Eşik)'] = np.where(
    olasiliklar >= 0.38, ' GİDECEK (Riskli)', ' KALACAK (Sadık)'
)

print('\n' + '=' * 85)
print('                İGDAŞ CANLI MÜŞTERİ CHURN TAHMİN RAPORU')
print('=' * 85)
print(rapor_bilgileri.to_string(index=False))
print('=' * 85)