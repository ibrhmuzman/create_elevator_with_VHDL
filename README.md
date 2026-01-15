VHDL Asansör Kontrol Sistemi

Bu projede, 4 katlı bir asansör için FSM (Sonlu Durum Makinesi) tabanlı bir kontrol sistemi tasarlanmıştır. Sistem; dış kat çağrıları ve kabin içi çağrıları birlikte alarak FCFS (ilk gelen ilk işlenir) mantığında çalışır.

Asansör; bekleme, yukarı hareket, aşağı hareket, kapı açma ve kapı kapama durumları arasında geçiş yapar. Hareket ve kapı kontrolü motor ve kapı sinyalleriyle sağlanır. Zamanlamalar generic parametreler ile tanımlanmış olup simülasyon ortamına uygun şekilde ölçeklenmiştir.

Tasarımda aşırı yük ve acil durum senaryoları özellikle ele alınmıştır. Bu durumlarda motorlar durdurulur ve kapı güvenlik amacıyla açık tutulur. Çağrılar bir kuyruk yapısında saklandığı için birden fazla isteğin kaybolmadan işlenmesi sağlanır.

Proje, farklı senaryoları kapsayan testbench’ler ile simülasyon ortamında doğrulanmıştır. Simülasyon çıktılarında asansörün sırasıyla hangi kata gittiği, motor ve kapı sinyallerinin doğru zamanda aktif olduğu gözlemlenmiştir.
