# Quick Start Guide - Hızlı Başlangıç Kılavuzu

## Adım 1: Dosyaları İndirin (Step 1: Download Files)

Tüm proje dosyalarını bilgisayarınıza indirin veya klonlayın:

```bash
git clone https://github.com/ibrhmuzman/create_elevator_with_VHDL.git
cd create_elevator_with_VHDL
```

## Adım 2: Vivado'yu Açın (Step 2: Open Vivado)

1. Xilinx Vivado'yu başlatın
2. Ana menüden başlatın (herhangi bir proje açmayın)

## Adım 3: Simülasyonu Çalıştırın (Step 3: Run Simulation)

### Yöntem A: Otomatik (TCL Script ile)

Vivado TCL Console'da:

```tcl
cd [proje_dizini]
source simulate.tcl
```

**Beklenilen Sonuçlar:**
- Proje otomatik oluşturulacak
- Simülasyon başlayacak
- Dalga formları görünecek
- Console'da test mesajları görünecek

### Yöntem B: Manuel

1. **Proje Oluşturun:**
   - File → New Project
   - İsim: `elevator_project`
   - Type: RTL Project
   - Part: `xc7a35tcpg236-1` (veya elinizde olan FPGA)

2. **Dosyaları Ekleyin:**
   - Add Sources → Add or Create Design Sources
   - `elevator_controller.vhd` dosyasını ekleyin
   
3. **Testbench Ekleyin:**
   - Add Sources → Add or Create Simulation Sources
   - `elevator_controller_tb.vhd` dosyasını ekleyin

4. **Simülasyonu Başlatın:**
   - Flow Navigator → Simulation → Run Simulation → Run Behavioral Simulation
   - TCL Console'da: `run 50000 ns`

## Adım 4: Dalga Formlarını İnceleyin (Step 4: Examine Waveforms)

### Eklenecek Önemli Sinyaller:

**Temel Sinyaller:**
- `clk` - Saat sinyali
- `reset` - Reset sinyali
- `floor_req[3:0]` - Kat istekleri
- `current_floor[1:0]` - Mevcut kat
- `door_open` - Kapı durumu
- `moving` - Hareket durumu
- `direction` - Yön

**İç Sinyaller (Debug için):**
- `current_state` - Mevcut durum
- `next_state` - Sonraki durum
- `timer_count` - Zamanlayıcı
- `floor_requests` - Kayıtlı istekler
- `target_floor` - Hedef kat

### Dalga Formunu Analiz Etme:

1. **Zoom to Fit**: Toolbar'dan veya `Ctrl+F` ile tüm simülasyonu görün

2. **State Transitions**: 
   - `current_state` sinyaline dikkat edin
   - Her durum geçişini gözlemleyin
   - FSM_DIAGRAM.md ile karşılaştırın

3. **Timing Analysis**:
   - Timer değerlerini kontrol edin
   - Kat değişim zamanlamalarını ölçün
   - Kapı açılma/kapanma sürelerini doğrulayın

4. **Console Output**:
   - TCL Console'da test sonuçlarını okuyun
   - "MONITOR:" mesajlarını takip edin
   - "PASSED" mesajlarını kontrol edin

## Adım 5: Testbench'i Anlayın (Step 5: Understand Testbench)

### Test Senaryoları:

1. **Test 1: Reset**
   ```vhdl
   reset <= '1';
   wait for clk_period * 10;
   reset <= '0';
   ```
   - Asansör 0. kata gitmeli
   - Kapılar kapalı olmalı

2. **Test 2: Aynı Kat**
   ```vhdl
   floor_req <= "0001";  -- Kat 0 isteği
   ```
   - Kapılar açılmalı
   - Hareket olmamalı

3. **Test 3: Yukarı Hareket**
   ```vhdl
   floor_req <= "0010";  -- Kat 1 isteği
   ```
   - `moving = 1`, `direction = 1`
   - Kat değişmeli

4. **Test 4-7**: Diğer senaryolar

### Kendi Testinizi Yazın:

```vhdl
-- Kat 2'ye git
floor_req <= "0100";
wait for clk_period;
floor_req <= "0000";
wait for clk_period * 300;
```

## Adım 6: Sentez Yapın (Step 6: Synthesize)

**Opsiyonel - İleri düzey kullanıcılar için**

```tcl
source synthesize.tcl
```

**Sonuçlar:**
- `elevator_utilization.rpt`: FPGA kaynak kullanımı
- `elevator_timing.rpt`: Zamanlama analizi

### Kaynak Kullanımı Örnekleri:

- LUTs: ~50-100
- Flip-Flops: ~20-30
- Maximum Frequency: 100+ MHz

## Adım 7: Deneyler Yapın (Step 7: Experiments)

### Deney 1: Zamanlama Değiştirme

`elevator_controller.vhd` içinde:

```vhdl
constant DOOR_WAIT_TIME  : unsigned(7 downto 0) := to_unsigned(100, 8);  -- Artırın
```

**Gözlem:** Kapının daha uzun süre açık kaldığını görün.

### Deney 2: Kat Sayısını Artırma

1. `floor_req` ve `current_floor` bit genişliklerini değiştirin
2. Testbench'i güncelleyin
3. Yeniden simüle edin

### Deney 3: Yeni Özellik Ekleme

**Acil Durum Butonu:**

```vhdl
emergency : in STD_LOGIC;
```

FSM'e yeni durum ekleyin:
```vhdl
type state_type is (IDLE, ..., EMERGENCY_STOP);
```

### Deney 4: Öncelik Mantığı

Aşağı giderken aşağı yöndeki isteklere öncelik verin:

```vhdl
-- MOVING_DOWN durumunda
-- Önce aşağı yöndeki istekleri kontrol et
for i in 0 to to_integer(current_floor_reg)-1 loop
    if floor_requests(i) = '1' then
        target_floor <= to_unsigned(i, 2);
        exit;
    end if;
end loop;
```

## Troubleshooting (Sorun Giderme)

### Problem 1: Simülasyon Başlamıyor

**Çözüm:**
- Tüm dosyaların doğru eklendiğinden emin olun
- Top module'ün `elevator_controller_tb` olduğunu kontrol edin
- Compile order'ı güncelleyin

### Problem 2: Hatalı Çıkışlar

**Çözüm:**
- Console'daki error mesajlarını okuyun
- Assert mesajlarına dikkat edin
- Dalga formunda kritik sinyalleri inceleyin

### Problem 3: Sentez Hataları

**Çözüm:**
- Sadece `elevator_controller.vhd` sentezlenmelidir
- Testbench sentezlenmez
- Synthesis ayarlarını kontrol edin

## Öğrenme Checklistesi (Learning Checklist)

Şunları yapabildiğinizden emin olun:

- [ ] Vivado'da yeni proje oluşturabiliyorum
- [ ] VHDL dosyalarını ekleyebiliyorum
- [ ] Simülasyonu çalıştırabiliyorum
- [ ] Dalga formlarını okuyabiliyorum
- [ ] FSM durumlarını anlayabiliyorum
- [ ] Testbench yazabiliyorum
- [ ] Timing sabitlerini değiştirebiliyorum
- [ ] Assert kullanabiliyorum
- [ ] TCL script çalıştırabiliyorum
- [ ] Sentez raporu okuyabiliyorum

## Sonraki Adımlar (Next Steps)

1. **FSM_DIAGRAM.md** dosyasını okuyun - detaylı FSM açıklaması
2. Kendi tasarımınızı yapın (trafik ışığı, otomatik kapı, vb.)
3. Daha karmaşık FSM'ler oluşturun
4. Gerçek FPGA kartında test edin

## Yararlı Kaynaklar (Useful Resources)

- Vivado User Guide: UG893, UG894
- VHDL Tutorial: https://www.nandland.com/vhdl/tutorials/
- FSM Design: "Finite State Machines in Hardware" book
- Xilinx Forums: https://forums.xilinx.com/

## Destek (Support)

Sorularınız için:
- Issue açın: GitHub Issues
- Detaylı açıklama: FSM_DIAGRAM.md
- README: Ana dokümantasyon

---

**İyi Çalışmalar! / Good Luck!** 🚀
