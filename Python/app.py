import streamlit as st
import pandas as pd 
import joblib
import numpy as np
import matplotlib.pyplot as plt
import os

st.set_page_config(page_title="   Müşteri Churn Tahmin Paneli", layout="wide",page_icon="⚡",menu_items={
        'About': " Bu uygulama  Müşteri Kayıp Analizi için geliştirilmiştir."
    })

@st.cache_resource
def kaynaklari_yukle():
    base_dir = os.path.dirname(os.path.abspath(__file__))

    # Bir üst klasöre ('..') çıkıp 'models' klasörünün içindeki dosyalara ulaşır
    model_yolu = os.path.join(base_dir, "..", "models", "xgb_churn_model.pkl")
    sutun_yolu = os.path.join(base_dir, "..", "models", "model_sutunlari.pkl")

    model = joblib.load(model_yolu)
    sutunlar = joblib.load(sutun_yolu)
    return model, sutunlar

xgb_model, model_sutunlari = kaynaklari_yukle()

st.title("⚡  Müşteri Churn Tahmin Sistemi")
st.markdown(" XGBoost sınıflandırma algoritması  ve  $0.38$ optimize karar eşiği ile müşteri ayrılma risk analizi.")
st.markdown("---")

tab1,tab2,tab3 =st.tabs([
    "🎯 Tekil Müşteri Risk Simülasyonu", 
    "📋 Canlı Toplu Müşteri Skorlama Tablosu", 
    "📊 Model Değişken Önem Analizi (Feature Importance)"
])

with tab1 :

     st.sidebar.header("📊 Tüketim & Finansal Parametreler")
 
     net_kar = st.sidebar.number_input("Net Kar Marji (TL)" ,min_value= -1000.0,max_value=100000.0 ,step=100.0 , value=1800.0)
     elektrik_tüketim=st.sidebar.number_input("Elektrik Tüketimi 12 Ay" ,min_value=0.0,max_value =10000000.0,step =1000.0 ,value= 35000.0)
     sozlesme_gun= st.sidebar.number_input("Söleşme Süresi Gün" ,min_value=1 ,max_value=5000,step=30,value=1460 )
     gaz_tuketim=st.sidebar.number_input( "Gaz Tüketimi 12 Ay" ,min_value=0.0 ,max_value=5000000.0 ,step=1000.0, value=0.0 )
     odenen_tuketim=st.sidebar.number_input("Ödenen Tüketim Tutarı TL", min_value=0.0,max_value=500000.0 ,step= 500.0, value=12000.0)
     tahmini_tuketim=st.sidebar.number_input("Tahmini Tüketim 12 Ay",min_value=0.0,max_value=5000000.0,step=1000.0,value=45000.0)
     abone_gucu=st.sidebar.number_input("Abone Gücü Max KW" ,min_value=0.0 ,max_value=50000.0,step =10.0,value=132.0)
     tahmini_indirim=st.sidebar.selectbox("Tahmini Enerji İndirimi ", [0,300])
     dogalgaz_abonesimi=st.sidebar.selectbox("Doğalgaz Abone Durumu" ,[0,1])
 
     st.sidebar.markdown("---")
     st.sidebar.header("🏷️ Segmentasyon ve Kategoriler")
 
     satis_kanali=st.sidebar.selectbox(" Satış Kanalı",["Kanal A","Kanal B" ,"Kanal C","Kanal D"])
     kampanya_tipi=st.sidebar.selectbox("kampanya Tipi",["Kampanya 1","Kampanya 2","Diger Kampanya"])
     indirim_segmenti=st.sidebar.selectbox("İndirim Segmenti" ,[ "1-Hiç İndirim Almayanlar","2-Standart İndirim Alanlar","3-Yüksek İndirim Alanlar"])
     kapasite_segmenti = st.sidebar.selectbox("Müşteri Kapasite Segmenti", ["1- Atıl Kapasite", "2- Dengeli Tüketim", "3- Büyük Tüketici"])
     profil_segmenti = st.sidebar.selectbox("Müşteri Profil Segmenti", [ "1- Sadece Elektrik - Yüksek Tüketici", "2- Sadece Elektrik - Standart Tüketici", "3- Doğalgaz+Elektrik - Yüksek Tüketici"])

     # Özellik Mühendisliği Hesaplamaları
     toplam_tuketim = elektrik_tüketim + gaz_tuketim
     birim_basina_kar = net_kar / (toplam_tuketim + 1e-5)
     tahmin_sapmasi = toplam_tuketim / (tahmini_tuketim + 1e-5)
     fiyat_dalgalanma_orani = 0.15

     if st.button("🔍 Müşteri Risk Durumunu Hesapla",use_container_width=True):

    # Girdi Verisini Sözlük Olarak Hazırlama

       input_data = {
        "Elektrik_Tuketimi_12Ay": elektrik_tüketim,
        "Gaz_Tuketimi_12Ay": gaz_tuketim,
        "Odenen_Tuketim": odenen_tuketim,
        "Net_Kar_Marji": net_kar,
        "Tahmini_Enerji_Indirimi": tahmini_indirim,
        "Tahmini_Tuketim_12Ay": tahmini_tuketim,
        "Abone_Gucu_Max_kW": abone_gucu,
        "Dogalgaz_Abonesi_Mi": dogalgaz_abonesimi,
        "Sozlesme_Suresi_Gun": sozlesme_gun,
        "Birim_Başina_kar": birim_basina_kar,
        "Tahmini_sapmasi": tahmin_sapmasi,
        "Fiyat_Dalgalanma_Orani": fiyat_dalgalanma_orani,
        "Satis_Kanali": satis_kanali,
        "Kampanya_Tipi": kampanya_tipi,
        "Indirim_Segmenti": indirim_segmenti,
        "Musteri_Kapasite_Segmenti": kapasite_segmenti,
        "Musteri_Profil_Segmenti": profil_segmenti
      }
 
     df_input=pd.DataFrame(["input_data"])
     df_encoded=pd.get_dummies(df_input)
     model_girdisi=df_encoded.reindex(columns= model_sutunlari,fill_value=0)
     churn_prob=xgb_model.predict_proba(model_girdisi)[0][1]
     optimum_esik=0.38

     st.markdown("---")
     st.subheader("📋 Model Analiz ve Karar Raporu")
  
     col1, col2, col3 = st.columns(3)
     fark = (churn_prob - optimum_esik) * 100

     with col1:
          st.metric(label="Ayrılma (Churn) İhtimali", value=f"%{churn_prob * 100:.2f}",delta=f"{fark:+.2f}% Eşik Farkı",delta_color="inverse")
 
     with col2:
          st.metric(label="Optimum Karar Eşiği", value=f"{optimum_esik}")

     with col3:
          if churn_prob >= optimum_esik:
              st.error(" MODEL KARARI: GİDECEK (Riskli)")
          else:
              st.success(" MODEL KARARI: KALACAK (Sadık)")
     # Bilgilendirici İpucu
     if churn_prob >= optimum_esik:
       st.warning("⚠️ Aksiyon Önerisi: Müşterinin ayrılma riski yüksek. Özel kampanya veya indirim tanımlanması önerilir.")
     else:
       st.info("ℹ️ Müşteri Durumu: Müşteri portföyde kalma eğiliminde. Standart tarife akışı sürdürülebilir.")

with tab2:
    st.subheader("📑 SQL Canlı Test Verisi Skorlama Tablosu")
    st.markdown("Veritabanına yeni eklenen test müşterilerinin toplu skorlama ve karar dökümü tahminleri:")
 
    test_data = [
        {"Musteri_ID": "NEW_CLIENT_001", "Satis_Kanali": "Kanal B", "Kampanya_Tipi": "Kampanya 2", "Net_Kar_Marji": 1800.0, "Ayrilma_Ihtimali": 0.0794, "Karar": "KALACAK"},
        {"Musteri_ID": "NEW_CLIENT_002", "Satis_Kanali": "Kanal D", "Kampanya_Tipi": "Kampanya 3", "Net_Kar_Marji": 650.0, "Ayrilma_Ihtimali": 0.8387, "Karar": "GİDECEK"},
        {"Musteri_ID": "NEW_CLIENT_003", "Satis_Kanali": "Kanal A", "Kampanya_Tipi": "Diger Kampanya", "Net_Kar_Marji": 3500.0, "Ayrilma_Ihtimali": 0.1892, "Karar": "KALACAK"},
        {"Musteri_ID": "NEW_CLIENT_004", "Satis_Kanali": "Kanal B", "Kampanya_Tipi": "Kampanya 1", "Net_Kar_Marji": 1200.0, "Ayrilma_Ihtimali": 0.8817, "Karar": "GİDECEK"},
        {"Musteri_ID": "TEST_9901", "Satis_Kanali": "Kanal B", "Kampanya_Tipi": "Kampanya 1", "Net_Kar_Marji": 5.2, "Ayrilma_Ihtimali": 0.1378, "Karar": "KALACAK"},
        {"Musteri_ID": "TEST_9902", "Satis_Kanali": "Kanal A", "Kampanya_Tipi": "Diger Kampanya", "Net_Kar_Marji": 45.5, "Ayrilma_Ihtimali": 0.2072, "Karar": "KALACAK"},
        {"Musteri_ID": "TEST_9903", "Satis_Kanali": "Kanal D", "Kampanya_Tipi": "Kampanya 3", "Net_Kar_Marji": 25.1, "Ayrilma_Ihtimali": 0.0704, "Karar": "KALACAK"},
        {"Musteri_ID": "TEST_9904", "Satis_Kanali": "Kanal B", "Kampanya_Tipi": "Kampanya 2", "Net_Kar_Marji": 15.1, "Ayrilma_Ihtimali": 0.0354, "Karar": "KALACAK"},
        {"Musteri_ID": "TEST_9905", "Satis_Kanali": "Kanal A", "Kampanya_Tipi": "Diger Kampanya", "Net_Kar_Marji": 520.0, "Ayrilma_Ihtimali": 0.0145, "Karar": "KALACAK"},
        {"Musteri_ID": "TEST_9906", "Satis_Kanali": "Kanal B", "Kampanya_Tipi": "Kampanya 1", "Net_Kar_Marji": 31000.0, "Ayrilma_Ihtimali": 0.0078, "Karar": "KALACAK"}
    ]

    df_test=pd.DataFrame(test_data)
    df_test["Ayrilma_Ihtimali_Gosterimi"]=df_test["Ayrilma_Ihtimali"].apply(lambda x: f"%{x*100:.2f}")

    def stil_uygula(val):
        if val == "GİDECEK":
            return  "background-color: #F8D7DA; color: #721C24; font-weight: bold;"
        elif val =="KALACAK":
            return "background-color: #d4edda; color: #155724; font-weight: bold;"
        return ""

    tablo=df_test[["Musteri_ID", "Satis_Kanali", "Kampanya_Tipi", "Net_Kar_Marji", "Ayrilma_Ihtimali_Gosterimi", "Karar"]]
    #styled_tablo = tablo.style.applymap(stil_uygula, subset=["Karar"]).format({"Net_Kar_Marji": "{:.2f} TL"})
    styled_tablo = tablo.style.map(stil_uygula, subset=["Karar"]).format({"Net_Kar_Marji": "{:.2f} TL"})
    
    #st.dataframe(styled_tablo, use_container_width=True)
    st.table(styled_tablo)

    st.divider()
    st.subheader("🧪 Model Karşılaştırma & Simülasyon Stres Testi")
    
    col_analiz1, col_analiz2 = st.columns(2)

    # Sol: Algoritma Metrik Kıyaslama Raporu
    with col_analiz1:
        st.write("#### 📊 Algoritma Karşılaştırma Raporu")
        
        tablo1_html = """
        <div style="overflow-x:auto;">
        <table style="width:100%; border-collapse: collapse; font-family: sans-serif; font-size: 13px; text-align: center; border: 1px solid #7952b3;">
            <thead>
                <tr style="background-color: #2e9bb0; color: white; border-bottom: 2px solid #563d7c;">
                    <th style="padding: 9px 6px;">#</th>
                    <th style="padding: 9px 6px; text-align: left;">Model</th>
                    <th style="padding: 9px 6px;">Recall</th>
                    <th style="padding: 9px 6px;">Precision</th>
                    <th style="padding: 9px 6px;">F1-score</th>
                    <th style="padding: 9px 6px;">ROC-AU</th>
                </tr>
            </thead>
            <tbody>
                <tr style="background-color: #f2f9fa; color: #111; border-bottom: 1px solid #ddd;">
                    <td style="padding: 8px; font-weight: bold; background-color: #2e9bb0; color: white;">0</td>
                    <td style="padding: 8px; text-align: left; font-weight: 500;">Random Forest (0.15 Eşik)</td>
                    <td style="padding: 8px;">0.35</td>
                    <td style="padding: 8px;">0.18</td>
                    <td style="padding: 8px;">0.24</td>
                    <td style="padding: 8px; font-weight: 600;">0.78</td>
                </tr>
                <tr style="background-color: #e1f3f5; color: #111; border-bottom: 1px solid #7952b3;">
                    <td style="padding: 8px; font-weight: bold; background-color: #2e9bb0; color: white;">1</td>
                    <td style="padding: 8px; text-align: left; font-weight: 600; color: #0f4c5c;">XGBoost (0.38 Eşik)</td>
                    <td style="padding: 8px; font-weight: bold; color: #0a5c36;">0.59</td>
                    <td style="padding: 8px;">0.14</td>
                    <td style="padding: 8px;">0.23</td>
                    <td style="padding: 8px; font-weight: 600;">0.60</td>
                </tr>
            </tbody>
        </table>
        </div>
        """
        st.markdown(tablo1_html, unsafe_allow_html=True)
        st.caption("💡 **Açıklama:** XGBoost modeli optimize edilen $0.38$ eşik değeri ile kaçacak müşterileri yakalama oranını (Recall) %35'ten **%59'a** çıkarmıştır.")

    # 2. BÖLÜM: TEST_9901 Stres Testi Raporu
    with col_analiz2:
        st.write("#### ⚡ TEST_9901 Müşterisi Stres Testi")
        
        tablo2_html = """
        <div style="overflow-x:auto;">
        <table style="width:100%; border-collapse: collapse; font-family: sans-serif; font-size: 12px; text-align: center; border: 1px solid #7952b3;">
            <thead>
                <tr style="background-color: #2e9bb0; color: white; border-bottom: 2px solid #563d7c;">
                    <th style="padding: 8px 4px;">#</th>
                    <th style="padding: 8px 4px;">Musteri_ID</th>
                    <th style="padding: 8px 4px;">Satis_Kanali</th>
                    <th style="padding: 8px 4px;">Kampanya</th>
                    <th style="padding: 8px 4px;">Net_Kar</th>
                    <th style="padding: 8px 4px;">Ayrılma %</th>
                    <th style="padding: 8px 4px;">Eski %</th>
                    <th style="padding: 8px 4px; background-color: #237a8b;">Stres %</th>
                    <th style="padding: 8px 4px; background-color: #237a8b;">Karar</th>
                </tr>
            </thead>
            <tbody>
                <tr style="background-color: #e1f3f5; color: #111;">
                    <td style="padding: 8px; font-weight: bold; background-color: #2e9bb0; color: white;">4</td>
                    <td style="padding: 8px; font-weight: 600;">TEST_9901</td>
                    <td style="padding: 8px;">Kanal B</td>
                    <td style="padding: 8px;">Kampanya 1</td>
                    <td style="padding: 8px;">5.20 TL</td>
                    <td style="padding: 8px; font-weight: 600;">%13.78</td>
                    <td style="padding: 8px;">%13.78</td>
                    <td style="padding: 8px; font-weight: bold; color: #0a5c36;">%5.50</td>
                    <td style="padding: 8px; font-weight: bold; background-color: #d4edda; color: #155724;">KALACAK</td>
                </tr>
            </tbody>
        </table>
        </div>
        """
        st.markdown(tablo2_html, unsafe_allow_html=True)
        st.caption("🔍 **Senaryo Analizi:** Modelin sınırlarını test etmek için müşterinin kârlılığını düşürüp sözleşme süresini kısalttığımız stres senaryosunda model kararlılığını korumuştur.")
with tab3:
    st.subheader("📊 Model Değerlendirme ve Karar Faktörleri (Feature Importance)")
    st.markdown("XGBoost modelinin ayrılma riskini belirlerken en çok baktığı ilk 15 değişken ve $0.38$ eşiğindeki başarı matrisi:")

    col_grafik1, col_grafik2 = st.columns([1.2, 1])

    # 1. GRAFİK: En Etkili 15 Değişken (Sol Sütun)
    with col_grafik1:
        st.write("#### 🎯 En Etkili 15 Değişken (Feature Importance)")
        try:
            df_importance = pd.DataFrame({
                'Öznitelik': list(model_sutunlari),
                'Önem_Derecesi': list(xgb_model.feature_importances_)
            }).sort_values(by='Önem_Derecesi', ascending=True).tail(15)

            fig1, ax1 = plt.subplots(figsize=(9, 8))
            bars = ax1.barh(df_importance['Öznitelik'], df_importance['Önem_Derecesi'], color='#17878a', height=0.45)

            for bar in bars:
                width = bar.get_width()
                ax1.text(width + 0.002, bar.get_y() + bar.get_height() / 2, f'{width:.3f}', 
                         va='center', ha='left', fontsize=10, fontweight='bold')

            ax1.set_xlabel('Önem Skoru (Gain)', fontsize=11, fontweight='bold')
            ax1.set_ylabel('Değişkenler', fontsize=11, fontweight='bold')
            ax1.tick_params(axis='both', labelsize=10)
            ax1.set_title('Müşteri Kaybına Etki Eden En Önemli 15 Faktör', fontsize=12, fontweight='bold')
            ax1.grid(axis='x', linestyle='--', alpha=0.5)
            plt.tight_layout()
            st.pyplot(fig1, use_container_width=True)

        except Exception as e:
            st.error(f"Grafik çizilirken hata oluştu: {e}")

    # 2. GRAFİK: Confusion Matrix (Sağ Sütun - Girintisi Düzeltildi)
    with col_grafik2:
        st.write("#### ⚡ 0.38 Confusion Matrix (Test Başarısı)")
        try:
            cm_matrix = [[1630, 949], 
                         [111,  169]]
             
            fig2, ax2 = plt.subplots(figsize=(6, 6))
            cax = ax2.matshow(cm_matrix, cmap='Greens')
            fig2.colorbar(cax, fraction=0.046, pad=0.04)

            # Döngüsüz hücre metinleri
            ax2.text(0, 0, "1630", va='center', ha='center', fontsize=12, fontweight='bold', color='white')
            ax2.text(1, 0, "949",  va='center', ha='center', fontsize=12, fontweight='bold', color='darkgreen')
            ax2.text(0, 1, "111",  va='center', ha='center', fontsize=12, fontweight='bold', color='darkgreen')
            ax2.text(1, 1, "169",  va='center', ha='center', fontsize=12, fontweight='bold', color='darkgreen')

            ax2.set_xticks([0, 1])
            ax2.set_yticks([0, 1])
            ax2.set_xticklabels(['Kalacak (0)', 'Kaçacak (1)'], fontsize=9, fontweight='bold')
            ax2.set_yticklabels(['Kalacak (0)', 'Kaçacak (1)'], fontsize=9, fontweight='bold')
            ax2.xaxis.set_ticks_position('bottom')

            ax2.set_xlabel('Tahmin Edilen Sınıf', fontsize=10, fontweight='bold')
            ax2.set_ylabel('Gerçek Sınıf', fontsize=10, fontweight='bold')
            ax2.set_title('Eşik Değeri 0.38 Sonrası Confusion Matrix', fontsize=11, fontweight='bold', pad=15)
            ax2.tick_params(axis='both', labelsize=9)
            plt.tight_layout()
            
            st.pyplot(fig2, use_container_width=True)

        except Exception as e:
            st.error(f"Matris çizilirken hata oluştu: {e}")
