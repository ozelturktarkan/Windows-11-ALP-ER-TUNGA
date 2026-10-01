# Sanal makine kurulumu

Bu sayfa bir kurulum rehberidir; bütün hipervizörlerde test sonucu anlamına gelmez.

- İlk deneme için 4 GB RAM, 64 GB sanal disk, UEFI ve varsa TPM 2.0 / Secure Boot kullanın. Projenin 1/2 GB hedefleri ayrıca ölçülmesi gereken deneylerdir.
- ISO'yu optik sürücüye takın. CD/DVD'den başlatma tuşu istendiğinde basın; dosyanın diskte bulunması VM'ye takıldığı anlamına gelmez.
- VirtualBox'ın otomatik/katılımsız kurulumunu atlayın; kurulum adımlarını Windows ekranında elle tamamlayın. Eski yardımcı unattended medyasını bağlı bırakmayın. ProductKey hatasında önce bu medyayı ve yanıt dosyasını kontrol edin.
- Ağ için NAT bağdaştırıcısı ve **Kablo bağlı** seçeneği açık olsun. KIZILELMA'nın önceki testinde bağlantı bu seçenekle düzeldi; ISO ayarı değiştirilmedi.
- Ses çıkışını ve konuk ses aygıtını kontrol edin. Bir VM'deki ses sorunu tek başına ISO bozukluğu kanıtı değildir.
- Siyah ekranda önce ISO hash'ini, bağlı medyayı, VM günlüğünü ve görüntü ayarlarını kontrol edin. Önceki LTSC denemesinde 3 vCPU ile kurulum ilerlese de sonrasında siyah ekran tekrarlandı; bunu kesin çözüm veya ISO bozukluğunun kanıtı saymıyoruz.

Bu adayların temiz kurulum yanıt dosyası yalnız TPM, Secure Boot ve RAM denetimleri için LabConfig değerlerini ekler. CPU komut seti, sürücü veya her donanımda çalışma engellerini kaldırdığı iddia edilmez. Ana bilgisayarın TPM/firmware ayarları değiştirilmez.
