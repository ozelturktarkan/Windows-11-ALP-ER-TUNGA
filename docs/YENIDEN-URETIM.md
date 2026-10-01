# Aynı profili kendiniz hazırlayın

Paylaşılan XML ve betikleri inceleyerek değişiklikleri kendiniz uygulayabilirsiniz. Yalnız XML, temayı ve kurulum eklerini içermez; **Medya-Eki de gereklidir**. Aynı ayarları uygulamak, ISO zaman damgaları ve paketleme araçları değiştiğinde birebir aynı ISO hash'ini garanti etmez.

1. README'de belirtilen sürüm, yapı, dil ve mimarideki kendi Windows medyanızı ayrı bir çalışma klasörüne çıkarın. Özgün kaynak ISO için doğrulanmış Microsoft hash'i bu depoda sunulmuş değildir; kaynak WIM hash'i ile ISO hash'ini karıştırmayın.
2. NTLite'da yalnız belirtilen Home/Pro imajını yükleyin. `NTLite/` XML ön ayarını uygulamadan önce dört kaldırmayı inceleyin. Üretimde NTLite 2026.9.12209 kullanıldı; ücretli bileşen işlemleri için uygun NTLite lisansı gerekebilir.
3. İmajı kaydedin ve hedef sürümü tek indeksli `sources/install.wim` olarak dışa aktarın. Diğer sürüm indekslerini dağıtıma katmayın.
4. Bu deponun `Medya-Eki/` içeriğini kurulum medyasının köküne, alt dizinleri koruyarak kopyalayın. `autounattend.xml` kökte, `$OEM$` klasörü `sources` altında olmalıdır. Ürün anahtarı, otomatik disk bölümlendirmesi ve aktivasyon betiği eklenmez.
5. Tema betiklerinin yollarını ve `Theme.json` dosyasındaki varlık hashlerini kontrol edin.
6. BIOS ve UEFI açılışı içeren, büyük WIM dosyasını destekleyen ISO üretin. Proje UDF 2.60 / ISO level 3 ile pycdlib 1.21.0 kullandı; farklı araçtan çıkan dosya aynı hash'i vermeyebilir. Çalışma klasöründeki eski otomatik kurulum/log dosyalarını yanlışlıkla eklemeyin.
7. ISO'nun SHA-256'sını hesaplayın; kurulum, ağ, ses, tema ve uygulamaları ayrı test edin. Yayın öncesi test sonucunu açıkça belgeleyin.

`Medya-Eki` içindeki PowerShell betikleri kurulan hedef Windows içindir. Bunları kendi çalışan ana bilgisayarınızda kurulum betiği gibi çalıştırmayın. Kaynak dosyaları kontrol etmek için `Araclar/Dosyalari-Dogrula.ps1`, indirdiğiniz özel ISO için `Araclar/ISO-Dogrula.ps1` kullanılabilir; ikisi de yalnız okur.
