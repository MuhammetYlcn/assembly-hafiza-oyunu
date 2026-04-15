; multi-segment executable file template.

data segment
    ; Kartlar ve Durumlar
    kartlar  db 'A','A','B','B','C','C','D','D','E','E','F','F','G','G','H','H'
    durumlar db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    
    acik_sayisi db 0    
    secilen1    dw 0    
    secilen2    dw 0    
    
    kalan_hamle  db 15   
    bulunan_cift db 0    
    
    baslangic_tiki dw 0    
    toplam_sure    dw 600   
    ceza_tiki      dw 0
    son_saniye     dw 0FFFFh 
    toplam_puan    dw 0

    ; --- EKRAN MESAJLARI ---
    msg_menu       db 10, 13, 10, 13, "      === HAFIZA OYUNU ===", 10, 13, 10, 13, " Baslamak icin bir tusa basin...$"
    msg_kazandin   db "TEBRIKLER! TUM KARTLARI BULDUN KAZANDIN!$"
    msg_kaybettin  db "HAMLEN VEYA SUREN BITTI! KAYBETTIN!$"
    msg_bilgi      db "Hamle: $"
    msg_sure       db "  Sure: $"
    msg_puan_txt   db "  Puan: $"
    str_bos_temizle db "      $" 
    msg_tekrar     db "Tekrar oynamak ister misin? (E/H): $"
    msg_final_skor db "FINAL SKORUN: $"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov es, ax

ana_menu:
    call ekrani_temizle
    mov ah, 09h
    lea dx, msg_menu
    int 21h
    mov ah, 00h
    int 16h

oyunu_sifirla:
    mov kalan_hamle, 15
    mov bulunan_cift, 0
    mov acik_sayisi, 0
    mov ceza_tiki, 0
    mov son_saniye, 0FFFFh
    mov toplam_puan, 0
    
    mov cx, 16
    mov si, 0
sifirla_dongu:
    mov durumlar[si], 0
    inc si
    loop sifirla_dongu

    ; --- KARTLARI KARIÞTIR ---
    mov cx, 30          
karistir_dongu:
    push cx             
    mov ah, 00h
    int 1Ah             
    mov ax, dx
    xor dx, dx
    mov bx, 16
    div bx
    mov si, dx          
    mov ah, 00h
    int 1Ah
    add dx, si          
    mov ax, dx
    xor dx, dx
    mov bx, 16
    div bx
    mov di, dx          
    mov al, kartlar[si]
    mov bl, kartlar[di]
    mov kartlar[si], bl
    mov kartlar[di], al
    pop cx              
    loop karistir_dongu

oyun_basla:
    call ekrani_temizle   ; EKRANI ANINDA SIFIRLAR

    ; TÜM KARTLARI ÝLK BAÞTA KAPALI (MAVÝ) ÇÝZ
    mov si, 0
ilk_cizim_dongu:
    mov dh, 1Fh         ; 1Fh = Kapalý Renk (Mavi)
    call tek_kart_ciz
    inc si
    cmp si, 16
    jne ilk_cizim_dongu

    call istatistik_yazdir

    mov ah, 00h
    int 1Ah        
    mov baslangic_tiki, dx

oyun_dongusu:
    mov ah, 00h
    int 1Ah        
    sub dx, baslangic_tiki 
    add dx, ceza_tiki      
    
    mov ax, dx
    mov bx, 5
    mul bx          
    mov bx, 91
    div bx          
    
    cmp ax, toplam_sure    
    jae oyunu_kaybettin

    cmp ax, son_saniye     
    je klavye_kontrol
    mov son_saniye, ax
    call istatistik_yazdir 

klavye_kontrol:
    mov ah, 01h
    int 16h
    jz oyun_dongusu

    mov ah, 00h
    int 16h                
    
    sub al, 'a'          
    mov ah, 0
    mov si, ax           
    
    cmp si, 15
    ja oyun_dongusu
    cmp durumlar[si], 0
    jne oyun_dongusu
    
    mov durumlar[si], 1   
    
    mov al, acik_sayisi
    cmp al, 0
    je ilk_kart_set
    
    mov secilen2, si
    mov acik_sayisi, 2
    mov dh, 2Fh             ; 2Fh = Açýk Renk (Yeþil)
    call tek_kart_ciz       
    call eslesme_kontrol
    jmp oyun_dongusu

ilk_kart_set:
    mov secilen1, si
    mov acik_sayisi, 1
    mov dh, 2Fh             
    call tek_kart_ciz
    jmp oyun_dongusu

; =======================================================
; YARDIMCI PROSEDÜRLER 
; =======================================================

; 2000 DÖNGÜYÜ SÝLDÝK -> TEK BÝR BIOS KOMUTU ÝLE EKRANI ANINDA TEMÝZLE
ekrani_temizle proc
    push ax
    push bx
    push cx
    push dx
    
    ; BIOS Ekran Kaydýrma Komutu (Tüm Ekraný Sil)
    mov ax, 0600h     ; AH=06h (Scroll Up), AL=00h (Tüm ekran)
    mov bh, 07h       ; 07h = Siyah arka plan, Gri yazý
    mov cx, 0000h     ; Sol üst köþe
    mov dx, 184Fh     ; Sað alt köþe
    int 10h
    
    ; Ýmleci baþa al
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
ekrani_temizle endp

istatistik_yazdir proc
    push ax
    push bx
    push cx
    push dx
    
    mov ah, 02h      
    mov bh, 0        
    mov dh, 0        
    mov dl, 0        
    int 10h
    
    mov ah, 09h
    lea dx, msg_bilgi
    int 21h
    mov al, kalan_hamle
    xor ah, ah
    call sayi_yazdir
    
    mov ah, 09h
    lea dx, msg_sure
    int 21h
    mov ax, son_saniye     
    call sayi_yazdir
    
    mov ah, 09h
    lea dx, msg_puan_txt
    int 21h
    mov ax, toplam_puan
    call sayi_yazdir

    mov ah, 09h
    lea dx, str_bos_temizle
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
istatistik_yazdir endp

tek_kart_ciz proc
    push ax
    push bx
    push cx
    push di
    push es

    mov ax, 0B800h
    mov es, ax

    mov al, 176
    cmp dh, 1Fh
    je tkc_basla
    mov al, kartlar[si]     

tkc_basla:
    push ax         
    
    mov ax, si
    mov bl, 4
    div bl          
    
    push ax
    mov al, ah
    mov bl, 9       
    mul bl
    mov cl, al      
    xor ch, ch      
    pop ax

    xor ah, ah
    mov bl, 5       
    mul bl
    add ax, 2       

    mov bl, 80
    mul bl
    add ax, cx
    shl ax, 1
    mov di, ax
    
    pop ax          

    ; Kartý Çiz (3 Satýr)
    mov es:[di], 218
    mov es:[di+1], dh
    mov es:[di+2], 196
    mov es:[di+3], dh
    mov es:[di+4], 196
    mov es:[di+5], dh
    mov es:[di+6], 196
    mov es:[di+7], dh
    mov es:[di+8], 196
    mov es:[di+9], dh
    mov es:[di+10], 196
    mov es:[di+11], dh
    mov es:[di+12], 191
    mov es:[di+13], dh
    add di, 160     

    mov es:[di], 179
    mov es:[di+1], dh
    mov es:[di+2], 32
    mov es:[di+3], dh
    mov es:[di+4], 32
    mov es:[di+5], dh
    mov es:[di+6], al   
    mov es:[di+7], dh
    mov es:[di+8], 32
    mov es:[di+9], dh
    mov es:[di+10], 32
    mov es:[di+11], dh
    mov es:[di+12], 179
    mov es:[di+13], dh
    add di, 160

    mov es:[di], 192
    mov es:[di+1], dh
    mov es:[di+2], 196
    mov es:[di+3], dh
    mov es:[di+4], 196
    mov es:[di+5], dh
    mov es:[di+6], 196
    mov es:[di+7], dh
    mov es:[di+8], 196
    mov es:[di+9], dh
    mov es:[di+10], 196
    mov es:[di+11], dh
    mov es:[di+12], 217
    mov es:[di+13], dh
    add di, 160

    ; Ýndeks Harfi
    mov ax, si
    add al, 'a'
    mov es:[di+6], al
    mov es:[di+7], 07h  

    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret
tek_kart_ciz endp

eslesme_kontrol proc
    dec kalan_hamle        
    call istatistik_yazdir

    cmp toplam_puan, 5
    jb puan_dusme_atla
    sub toplam_puan, 5
puan_dusme_atla:

    mov si, secilen1
    mov al, kartlar[si]
    mov si, secilen2
    mov bl, kartlar[si]
    
    cmp al, bl
    je eslesme_tamam
    
    add ceza_tiki, 91      
    
    mov dh, 4Fh             
    mov si, secilen1
    call tek_kart_ciz
    mov si, secilen2
    call tek_kart_ciz
    
    call bekle_kisa      
    
    mov si, secilen1
    mov durumlar[si], 0
    mov dh, 1Fh
    call tek_kart_ciz

    mov si, secilen2
    mov durumlar[si], 0
    mov dh, 1Fh
    call tek_kart_ciz

    jmp eslesme_bitir
    
eslesme_tamam:
    add toplam_puan, 100    
    call istatistik_yazdir
    inc bulunan_cift
    cmp bulunan_cift, 8
    je oyunu_kazandin

eslesme_bitir:
    mov acik_sayisi, 0
    cmp kalan_hamle, 0
    je oyunu_kaybettin
    ret
eslesme_kontrol endp

bekle_kisa proc
    mov cx, 03h     
    mov dx, 93E0h
    mov ah, 86h
    int 15h
    ret
bekle_kisa endp

sayi_yazdir proc
    push ax
    push bx
    push cx
    push dx
    mov cx, 0      
    mov bx, 10     
bolme_dongusu:
    mov dx, 0      
    div bx         
    push dx        
    inc cx         
    cmp ax, 0      
    jne bolme_dongusu
yazdirma_dongusu:
    pop dx         
    add dl, 48     
    mov ah, 02h
    int 21h        
    loop yazdirma_dongusu
    pop dx
    pop cx
    pop bx
    pop ax
    ret
sayi_yazdir endp

oyunu_kazandin:
    mov ax, toplam_sure
    sub ax, son_saniye
    mov bx, 2
    mul bx              
    add toplam_puan, ax
    
    mov ah, 02h
    mov bh, 0
    mov dh, 19          
    mov dl, 0
    int 10h
    mov ah, 09h          
    lea dx, msg_kazandin 
    int 21h
    
    mov ah, 02h
    mov dh, 20          
    mov dl, 0
    int 10h
    lea dx, msg_final_skor
    int 21h
    mov ax, toplam_puan
    call sayi_yazdir
    jmp tekrar_sor

oyunu_kaybettin:
    mov ah, 02h
    mov bh, 0
    mov dh, 19          
    mov dl, 0
    int 10h
    mov ah, 09h          
    lea dx, msg_kaybettin 
    int 21h
    
    mov ah, 02h
    mov dh, 20          
    mov dl, 0
    int 10h
    lea dx, msg_final_skor
    int 21h
    mov ax, toplam_puan
    call sayi_yazdir

tekrar_sor:
    mov ah, 02h
    mov bh, 0
    mov dh, 22          
    mov dl, 0
    int 10h
    mov ah, 09h
    lea dx, msg_tekrar
    int 21h

tekrar_bekle:
    mov ah, 00h
    int 16h
    cmp al, 'e'
    je oyunu_sifirla
    cmp al, 'E'
    je oyunu_sifirla
    cmp al, 'h'
    je bitir
    cmp al, 'H'
    je bitir
    jmp tekrar_bekle

bitir:
    call ekrani_temizle
    mov ax, 4c00h
    int 21h

code ends
end start