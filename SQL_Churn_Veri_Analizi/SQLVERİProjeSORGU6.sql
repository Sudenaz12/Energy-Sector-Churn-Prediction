--SORGU 6: Kaynak Kampanya Kıyaslamaları
Use  VeriProje;
Go

Select 
    ISNULL(Kaynak_Kampanya, 'Kampanyasız Gelen') AS Kampanya_Tipi,
    COUNT(DISTINCT Musteri_ID) AS Getirilen_Musteri_Sayısı,

    Format(AVG(Net_Kar_Marji),'N2', 'tr-TR') AS Kisi_Bası_Ort_Kar,
    Format(SUM(Net_Kar_Marji)/1000000 ,'N2', 'tr-TR') AS Ortalama_Net_Kar_Milyon,

    CAST(SUM(CASE WHEN Churn_Durumu = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS Churn_Orani_Yuzde

FROM vw_Final_Churn_Analizi
Group By Kaynak_Kampanya
ORDER BY Churn_Orani_Yuzde DESC;