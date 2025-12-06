# Elevator Controller FSM - State Diagram and Description

## FSM State Diagram (Durum Diyagramı)

```
                                  RESET
                                    │
                                    ▼
                            ┌───────────────┐
                    ┌───────┤     IDLE      ├───────┐
                    │       └───────┬───────┘       │
                    │               │               │
                    │          floor_req            │
                    │               │               │
                    │       ┌───────▼───────┐       │
                    │       │  Same Floor?  │       │
                    │       └───┬───────┬───┘       │
                    │           │ YES   │ NO        │
                    │           │       │           │
                    │           │   ┌───▼────────┐  │
                    │           │   │Target>Curr?│  │
                    │           │   └─┬────────┬─┘  │
                    │           │     │ YES    │ NO │
                    │           │     │        │    │
                    │      ┌────▼─────▼──┐ ┌──▼────▼────┐
                    │      │DOOR_OPENING │ │ MOVING_UP  │
                    │      └──────┬──────┘ └─────┬──────┘
                    │             │              │
                    │  timer>=    │              │ target
                    │  DOOR_MOVE  │              │ reached
                    │             │              │
                    │      ┌──────▼──────┐       │
                    │      │DOOR_OPEN_   │◄──────┘
                    │      │    WAIT     │
                    │      └──────┬──────┘
                    │             │
                    │  timer>=    │
                    │  DOOR_WAIT  │
                    │             │
                    │      ┌──────▼──────┐
                    │      │DOOR_CLOSING │
                    │      └──────┬──────┘
                    │             │
                    │  timer>=    │
                    │  DOOR_MOVE  │
                    │             │
                    └─────────────┘
                    
                ┌──────────────┐
                │ MOVING_DOWN  │
                └──────┬───────┘
                       │
                 target reached
                       │
                       └──────────► DOOR_OPENING
```

## State Descriptions (Durum Açıklamaları)

### 1. IDLE (Boşta)
**Açıklama (Description):** 
- Asansör hiçbir işlem yapmıyor, kapılar kapalı
- Yeni kat çağrısı bekleniyor

**Giriş Koşulları (Entry Conditions):**
- Başlangıç durumu (reset sonrası)
- Kapı kapanma işlemi tamamlandıktan sonra

**Çıkış Koşulları (Exit Conditions):**
- `floor_req` sinyali aktif olduğunda
- Hedef kat belirlendikten sonra

**Çıkışlar (Outputs):**
- `door_open = 0`
- `moving = 0`
- `direction = X` (don't care)

### 2. DOOR_OPENING (Kapı Açılıyor)
**Açıklama (Description):**
- Kapılar açılma sürecinde
- Timer ile kontrol ediliyor

**Giriş Koşulları (Entry Conditions):**
- Hedef kata ulaşıldığında
- Mevcut katta istek varsa

**Çıkış Koşulları (Exit Conditions):**
- `timer_count >= DOOR_MOVE_TIME` (20 clock cycle)

**Çıkışlar (Outputs):**
- `door_open = 1`
- `moving = 0`

### 3. DOOR_OPEN_WAIT (Kapı Açık Bekleme)
**Açıklama (Description):**
- Kapılar tamamen açık
- Yolcu giriş/çıkışı için bekleme

**Giriş Koşulları (Entry Conditions):**
- Kapı açılma işlemi tamamlandıktan sonra

**Çıkış Koşulları (Exit Conditions):**
- `timer_count >= DOOR_WAIT_TIME` (50 clock cycle)
- Mevcut kat isteği temizlenir

**Çıkışlar (Outputs):**
- `door_open = 1`
- `moving = 0`

### 4. DOOR_CLOSING (Kapı Kapanıyor)
**Açıklama (Description):**
- Kapılar kapanma sürecinde
- Timer ile kontrol ediliyor

**Giriş Koşulları (Entry Conditions):**
- Bekleme süresi dolduğunda

**Çıkış Koşulları (Exit Conditions):**
- `timer_count >= DOOR_MOVE_TIME` (20 clock cycle)

**Çıkışlar (Outputs):**
- `door_open = 0`
- `moving = 0`

### 5. MOVING_UP (Yukarı Hareket)
**Açıklama (Description):**
- Asansör yukarı doğru hareket ediyor
- Her `FLOOR_MOVE_TIME` süresinde bir kat ilerler

**Giriş Koşulları (Entry Conditions):**
- `target_floor > current_floor`

**Çıkış Koşulları (Exit Conditions):**
- `current_floor == target_floor`

**Çıkışlar (Outputs):**
- `door_open = 0`
- `moving = 1`
- `direction = 1` (yukarı)

**Özel Davranış (Special Behavior):**
- Her 100 clock cycle'da `current_floor` bir artırılır
- Timer sıfırlanır ve yeniden başlar

### 6. MOVING_DOWN (Aşağı Hareket)
**Açıklama (Description):**
- Asansör aşağı doğru hareket ediyor
- Her `FLOOR_MOVE_TIME` süresinde bir kat iner

**Giriş Koşulları (Entry Conditions):**
- `target_floor < current_floor`

**Çıkış Koşulları (Exit Conditions):**
- `current_floor == target_floor`

**Çıkışlar (Outputs):**
- `door_open = 0`
- `moving = 1`
- `direction = 0` (aşağı)

**Özel Davranış (Special Behavior):**
- Her 100 clock cycle'da `current_floor` bir azaltılır
- Timer sıfırlanır ve yeniden başlar

## Timing Constants (Zamanlama Sabitleri)

| Sabit (Constant)    | Değer (Value) | Açıklama (Description)                |
|---------------------|---------------|---------------------------------------|
| `DOOR_WAIT_TIME`    | 50 cycles     | Kapının açık kalma süresi            |
| `DOOR_MOVE_TIME`    | 20 cycles     | Kapının açılma/kapanma süresi        |
| `FLOOR_MOVE_TIME`   | 100 cycles    | Bir kat hareket etme süresi          |

**Not:** 10ns clock period ile:
- Kapı açık kalma: 500ns
- Kapı hareketi: 200ns
- Kat hareketi: 1000ns (1μs)

## Signal Descriptions (Sinyal Açıklamaları)

### Internal Signals (İç Sinyaller)

1. **`current_floor_reg`** (unsigned 2 bit)
   - Asansörün mevcut kat konumu
   - 0-3 arası değer alabilir
   - Sadece MOVING_UP/DOWN durumlarında güncellenir

2. **`target_floor`** (unsigned 2 bit)
   - Gidilecek hedef kat
   - `floor_requests` sinyalinden hesaplanır
   - En yakın veya en öncelikli istek seçilir

3. **`timer_count`** (unsigned 8 bit)
   - Zamanlama için kullanılan sayaç
   - Her durum için farklı maksimum değer
   - Durum değişimlerinde sıfırlanır

4. **`floor_requests`** (4 bit)
   - Aktif kat isteklerini tutar
   - Bit pozisyonu kat numarasını gösterir
   - Kat ulaşıldığında ilgili bit temizlenir

## FSM Design Patterns (Tasarım Kalıpları)

### Three-Process FSM (Üç Süreç FSM)

Bu tasarım standart üç-süreç FSM modelini kullanır:

1. **State Register Process** (`state_register`)
   - Senkron durum güncellemesi
   - Reset ve clock kontrolü
   - Kayıtlı sinyallerin güncellenmesi

2. **Next State Logic** (`next_state_logic`)
   - Kombinasyonel mantık
   - Mevcut durum ve girişlere göre sonraki durum
   - Hedef kat hesaplaması

3. **Output Logic** (`output_logic`)
   - Kombinasyonel mantık
   - Moore tipi FSM (çıkışlar sadece duruma bağlı)
   - Durumlara göre çıkış ataması

### State Encoding (Durum Kodlaması)

VHDL enumeration tipi kullanılır:
```vhdl
type state_type is (IDLE, DOOR_OPENING, DOOR_OPEN_WAIT, 
                    DOOR_CLOSING, MOVING_UP, MOVING_DOWN);
```

Sentez aracı otomatik olarak en uygun kodlamayı seçer (binary, one-hot, gray code, vb.)

## Educational Notes (Eğitim Notları)

### FSM Tasarım Prensipleri

1. **Clear State Definition**: Her durum net bir amaç için tanımlanmalı
2. **Complete Transitions**: Tüm olası geçişler tanımlanmalı
3. **Default Values**: Her durumda tüm çıkışlar atanmalı
4. **Reset State**: Güvenli bir başlangıç durumu olmalı

### Common Mistakes to Avoid (Kaçınılması Gereken Hatalar)

1. ❌ Kombinasyonel döngüler (latch oluşumu)
2. ❌ Eksik durum geçişleri
3. ❌ Clock domain crossing sorunları
4. ❌ Reset sinyalinin unutulması

### Best Practices (En İyi Uygulamalar)

1. ✅ Senkron reset kullanımı (FPGA için)
2. ✅ Tüm durumlar için default case
3. ✅ Timeout mekanizmaları
4. ✅ Kapsamlı testbench coverage

## Simulation Tips (Simülasyon İpuçları)

### Waveform'da İzlenmesi Gerekenler:

1. **State Transitions**
   - Durum geçişlerinin beklenen sırada olup olmadığı
   - Geçiş koşullarının doğruluğu

2. **Timing**
   - Timer değerlerinin doğru sayıp saymadığı
   - Sabitlerin doğru kullanımı

3. **Output Consistency**
   - Her durumda çıkışların tutarlılığı
   - Moore FSM özelliğinin korunması

4. **Edge Cases**
   - Aynı kata istek
   - Çoklu eş zamanlı istekler
   - Reset sırasında davranış

### Debug Scenarios (Hata Ayıklama Senaryoları)

1. Asansör hareket etmiyor → `floor_requests` kontrol et
2. Kapılar açılmıyor → Timer değerlerini kontrol et
3. Yanlış yön → Hedef kat hesaplamasını kontrol et
4. Sonsuz döngü → Durum geçiş koşullarını kontrol et
