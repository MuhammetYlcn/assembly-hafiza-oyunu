# 🎮 8086 Assembly - Hafıza Oyunu (Memory Game)

Bu proje, x86 Assembly dili kullanılarak **emu8086** emülatörü için geliştirilmiş, donanım seviyesinde optimizasyonlar içeren bir hafıza eşleştirme oyunudur. Standart konsol komutları yerine doğrudan Video RAM manipülasyonu kullanılarak yüksek performans hedeflenmiştir.

---

## ✨ Teknik Özellikler

* **Direct VGA Rendering (B800h):** `int 21h` gibi yavaş sistem çağrıları yerine doğrudan `0B800h` segmentine yazılır. Bu sayede sıfır titreme (flicker-free) ve anlık tazeleme hızı elde edilmiştir.
* **Seçici Çizim Motoru (Selective Rendering):** Her hamlede tüm ekranı baştan çizmek yerine, sadece durumu değişen kartın bellek adresi hesaplanarak ilgili bölge güncellenir.
* **Gerçek Zamanlı Zamanlayıcı:** BIOS saati (`int 1Ah`) üzerinden 18.2 Hz hassasiyetinde çalışan dinamik bir geri sayım sistemi ve ceza süresi mekanizması.
* **Dinamik Renk Yönetimi:** * 🟦 **Mavi:** Kapalı kartlar
    * 🟩 **Yeşil:** Doğru eşleşme
    * 🟥 **Kırmızı:** Hatalı seçim (Görsel geri bildirim)
* **Rastgele Dağıtım:** Sistem saatinden alınan "seed" değeri ile kartlar her açılışta farklı konumlara karıştırılır.

## 🛠️ Nasıl Çalıştırılır?

1.  Bilgisayarınızda **emu8086** emülatörünün yüklü olduğundan emin olun.
2.  Repo içerisindeki `.asm` uzantılı dosyayı emülatör ile açın.
3.  `Emulate` butonuna basın.
4.  Oyunun en akıcı hali için emülatör ekranındaki **"Delay"** ayarını **0** konumuna getirin.

## 🕹️ Oyun Kuralları

-   Kartları açmak için üzerlerinde yazan **a-p** arası harfleri kullanın.
-   Her yanlış eşleştirmede **5 puan** kaybedersiniz ve süreniz **5 saniye** azalır.
-   15 hamle içinde veya süreniz bitmeden tüm çiftleri bulmanız gerekir.
-   Oyun sonunda kalan süreniz puanınıza bonus olarak eklenir.

## 🧠 Geliştirici Notu
Bu proje, düşük seviyeli dillerde bellek yönetimi, donanım kesmeleri (interrupts) ve koordinat tabanlı grafik çizimi konularında pratik yapmak amacıyla geliştirilmiştir. Özellikle kartların ekrandaki `(Y * 80 + X) * 2` formülüyle bellek adreslenmesi, projenin temel yapı taşını oluşturur.
