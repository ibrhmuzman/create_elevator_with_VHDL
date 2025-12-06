# Elevator Controller with VHDL - FSM Educational Project

## Proje Hakkında (About the Project)

Bu proje, öğrencilerin VHDL dili ile sıralı devre tasarımı, FSM (Finite State Machine - Sonlu Durum Makinesi) modelleme, zamanlama yöntemi, testbench oluşturma ve Vivado üzerinde simülasyon pratiği yapmaları için hazırlanmıştır.

This project is designed for students to practice sequential circuit design in VHDL, FSM (Finite State Machine) modeling, timing methods, testbench creation, and simulation practice using Vivado.

## Dosyalar (Files)

### 1. `elevator_controller.vhd`
Ana asansör kontrol devresi. FSM tabanlı tasarım içerir.

Main elevator controller circuit. Contains FSM-based design.

**FSM Durumları (States):**
- `IDLE`: Asansör boşta, kapılar kapalı
- `DOOR_OPENING`: Kapılar açılıyor
- `DOOR_OPEN_WAIT`: Kapılar açık, bekleme
- `DOOR_CLOSING`: Kapılar kapanıyor
- `MOVING_UP`: Asansör yukarı hareket ediyor
- `MOVING_DOWN`: Asansör aşağı hareket ediyor

**Giriş Sinyalleri (Inputs):**
- `clk`: Sistem saati
- `reset`: Asenkron reset
- `floor_req[3:0]`: Kat çağrı butonları (0-3 arası katlar)

**Çıkış Sinyalleri (Outputs):**
- `current_floor[1:0]`: Mevcut kat konumu
- `door_open`: Kapı durumu (1=açık, 0=kapalı)
- `moving`: Hareket durumu
- `direction`: Yön (1=yukarı, 0=aşağı)

### 2. `elevator_controller_tb.vhd`
Kapsamlı test ortamı (testbench). Çeşitli test senaryolarını içerir.

Comprehensive testbench. Contains various test scenarios.

**Test Senaryoları (Test Cases):**
1. Reset testi
2. Aynı katta kapı açma
3. Bir kat yukarı hareket
4. Çoklu kat yukarı hareket
5. Aşağı hareket
6. Çoklu istek yönetimi
7. Hızlı ardışık istekler

### 3. `simulate.tcl`
Vivado simülasyon otomasyonu için TCL script.

TCL script for Vivado simulation automation.

### 4. `synthesize.tcl`
Vivado sentez otomasyonu için TCL script.

TCL script for Vivado synthesis automation.

## Vivado'da Simülasyon (Simulation in Vivado)

### Yöntem 1: TCL Script ile (Method 1: Using TCL Script)

1. Vivado'yu açın
2. TCL Console'da şu komutu çalıştırın:
   ```tcl
   source simulate.tcl
   ```
3. Simülasyon otomatik olarak çalışacak ve dalga formları gösterilecektir

### Yöntem 2: Manuel Kurulum (Method 2: Manual Setup)

1. Vivado'yu açın
2. "Create Project" → "RTL Project" seçin
3. Hedef cihaz seçin (örn: Artix-7, xc7a35tcpg236-1)
4. Kaynak dosyalarını ekleyin:
   - Design Sources: `elevator_controller.vhd`
   - Simulation Sources: `elevator_controller_tb.vhd`
5. "Run Simulation" → "Run Behavioral Simulation"
6. Simülasyonu başlatın: `run 50000 ns`

### Dalga Formu Analizi (Waveform Analysis)

Simülasyon sırasında şunları gözlemleyin:
- FSM durum geçişleri (`current_state`)
- Kat değişimleri (`current_floor`)
- Kapı açılma/kapanma zamanlamaları (`door_open`)
- Hareket yönü ve durumu (`moving`, `direction`)
- Zamanlayıcı sayaçları (`timer_count`)

## Sentez (Synthesis)

Tasarımı sentezlemek için:

```tcl
source synthesize.tcl
```

Sentez raporları:
- `elevator_utilization.rpt`: Kaynak kullanımı
- `elevator_timing.rpt`: Zamanlama analizi

## FSM Durum Diyagramı (FSM State Diagram)

```
                    ┌─────────────┐
                    │    IDLE     │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
           ┌────────┤   Request   ├────────┐
           │        └─────────────┘        │
           │                               │
    ┌──────▼──────┐              ┌────────▼────────┐
    │  MOVING_UP  │              │  MOVING_DOWN    │
    └──────┬──────┘              └────────┬────────┘
           │                               │
           │        ┌─────────────┐        │
           └────────►DOOR_OPENING ◄────────┘
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │DOOR_OPEN_   │
                    │   WAIT      │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │DOOR_CLOSING │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    IDLE     │
                    └─────────────┘
```

## Öğrenme Hedefleri (Learning Objectives)

Bu proje ile öğrenciler şunları öğrenecekler:

1. **FSM Tasarımı**: Sonlu durum makinesi kavramı ve VHDL implementasyonu
2. **Sıralı Devre Tasarımı**: Clock-based senkron devreler
3. **Zamanlama**: Timer-based kontrol mekanizmaları
4. **Testbench Yazımı**: Kapsamlı test senaryoları oluşturma
5. **Simülasyon**: Vivado simülasyon araçlarını kullanma
6. **Sentez**: FPGA kaynakları için sentez süreci

## Geliştirme Fikirleri (Enhancement Ideas)

Projeyi geliştirmek için:

1. Acil durum butonu ekleyin
2. Kapı sensörü ekleyin (güvenlik)
3. Birden fazla asansör koordinasyonu
4. Enerji tasarrufu modu
5. Kat gösterge displayleri (7-segment)
6. Ses sinyalleri (buzzer kontrolü)

## Gereksinimler (Requirements)

- Xilinx Vivado (2018.1 veya üzeri)
- VHDL simülasyon bilgisi
- Temel dijital tasarım bilgisi

## Lisans (License)

Bu proje eğitim amaçlıdır ve serbestçe kullanılabilir.

This project is for educational purposes and can be freely used.

## İletişim (Contact)

Sorularınız için issue açabilirsiniz.

For questions, please open an issue.