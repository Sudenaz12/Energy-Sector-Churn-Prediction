import pandas as pd
from sqlalchemy import create_engine

# Sunucu ve veritabanı bilgileri
sunucu = 'DESKTOP-6KLDFGH\\SQLEXPRESS01' 
veritabani = 'VeriProje'

# SQLAlchemy için bağlantı dizesi (Windows Authentication - pyodbc altyapısı ile)
baglanti_metni = f"mssql+pyodbc://@{sunucu}/{veritabani}?driver=ODBC+Driver+17+for+SQL+Server&trusted_connection=yes"

# Motoru (engine) oluştur
engine = create_engine(baglanti_metni)

# SQL View'unu doğrudan DataFrame'e oku
query = "SELECT * FROM vw_Final_Churn_Analizi"
df = pd.read_sql(query, engine)

# Verinin ilk 5 satırını ekrana yazdır (Terminalde görmek için print ekledik)
print(df.head())