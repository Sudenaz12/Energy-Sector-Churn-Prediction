--SORGU 5:Sadece Elektrik Kullananların Yoğun Saat Maliyetleri
Use  VeriProje;
Go
--gaz o olan elektrik kullanıyordur'
SElECT CASE WHEN Dogalgaz_Abonesi_Mi = 0 AND Tahmini_Tuketim_12Ay >10000  Then '1- Sadece Elektrik - Yüksek Tüketici (Riskli Grup)'
            WHEN Dogalgaz_Abonesi_Mi = 0 AND Tahmini_Tuketim_12Ay <10000  Then '2- Sadece Elektrik - Standat Düşük/Orta Tüketici '
            WHEN Dogalgaz_Abonesi_Mi = 1 AND Tahmini_Tuketim_12Ay > 10000  Then '3-Doğalgaz+Elektrik - Yüksek Tüketici (Kurumsal olabilir) '
            Else  '4-Doğalgaz+Elektrik - Standart Düşük Tüketici (Ev olabilir) '
       END AS Musteri_Profil_Segmenti,

       COUNT(DISTINCT Musteri_ID) AS Kisi_Sayisi,

       FORMAT (AVG(Yogun_saatteki_ücret) ,'N2', 'tr-TR') AS OrtHesap_Yogun_Ucreti,
       FORMAT (AVG(Yogun_saatteki_SBT_ucret) ,'N2', 'tr-TR') AS OrtHeasap_Yogun_SBT_Ucreti,
       FORMAT (AVG(Orta_Yogun_saatteki_SBT_ucret) ,'N2', 'tr-TR') AS OrtHesap_Orta_Yogun_SBT_Ucreti,

       -- Fiyatlandırma politikasının şirket kârlılığına etkisi
       FORMAT (AVG(Net_Kar_Marji) / 1000000 ,'N2', 'tr-TR') AS Ortalama_Net_Kar_Milyon,

      CAST(SUM(CASE WHEN Churn_Durumu = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Orani_Yuzde--terk etme oranı

FROM vw_Final_Churn_Analizi
Group By CASE WHEN Dogalgaz_Abonesi_Mi = 0 AND Tahmini_Tuketim_12Ay >10000  Then '1- Sadece Elektrik - Yüksek Tüketici (Riskli Grup)'
            WHEN Dogalgaz_Abonesi_Mi = 0 AND Tahmini_Tuketim_12Ay <10000  Then '2- Sadece Elektrik - Standat Düşük/Orta Tüketici '
            WHEN Dogalgaz_Abonesi_Mi = 1 AND Tahmini_Tuketim_12Ay > 10000  Then '3-Doğalgaz+Elektrik - Yüksek Tüketici (Kurumsal olabilir) '
            Else  '4-Doğalgaz+Elektrik - Standart Düşük Tüketici (Ev olabilir) '
          END
Order By AVG(Yogun_saatteki_ücret) DESC ;