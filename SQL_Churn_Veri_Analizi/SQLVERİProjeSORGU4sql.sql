--SORGU 4 :Tahmini Tüketim, Net Kâr Marjı ve Abone Gücü (Kapasite) İlişkisi
Use  VeriProje;
Go
Select CASE 
          WHEN Abone_Gucu_Max_kW  >50 AND Tahmini_Tuketim_12Ay <10000 Then '1- Atıl Kapasite (Yüksek Güç - Düşük Tüketim)'
          WHEN  Abone_Gucu_Max_kW <= 50 AND Tahmini_Tuketim_12Ay < 10000 THEN '2- Küçük Tüketici (Düşük Güç - Düşük Tüketim)'
          WHEN Tahmini_Tuketim_12Ay >= 10000 THEN '3- Büyük Tüketici (Yüksek Hacim)'
          ELSE '4-Diğer Tüketici'
       END AS Musteri_segmenti,
       COUNT(DISTINCT Musteri_ID) AS Kisi_Sayisi,

      FORMAT((SUM(Net_Kar_Marji) / NULLIF(SUM(Tahmini_Tuketim_12Ay), 0)), 'N2', 'tr-TR') AS Birim_Tuketim_Basina_Kar,

      -- Ortalama Kâr ve Sabit Ücret (SBT) Kıyaslaması
     FORMAT (AVG(Net_Kar_Marji),'N2', 'tr-TR') AS OrtHesap_Net_Kar,
     FORMAT (AVG(Yogun_saatteki_SBT_ucret) ,'N2', 'tr-TR') AS OrtHesap_Yogun_SBT_Ucreti
    
 FROM vw_Final_Churn_Analizi
 WHERE Abone_Gucu_Max_kW IS NOT NULL
 Group By CASE 
          WHEN Abone_Gucu_Max_kW  >50 AND Tahmini_Tuketim_12Ay <10000 Then '1- Atıl Kapasite (Yüksek Güç - Düşük Tüketim)'
          WHEN  Abone_Gucu_Max_kW <= 50 AND Tahmini_Tuketim_12Ay < 10000 THEN '2- Küçük Tüketici (Düşük Güç - Düşük Tüketim)'
          WHEN Tahmini_Tuketim_12Ay >= 10000 THEN '3- Büyük Tüketici (Yüksek Hacim)'
          ELSE '4-Diğer Tüketici'
       END
 ORDER BY (SUM(Net_Kar_Marji) / NULLIF(SUM(Tahmini_Tuketim_12Ay), 0)) DESC;