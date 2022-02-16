! inicijalizacija simulacije
dc x.1, x.9996
dc x.0, x.9998
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.1, r5, x.6
kpreg 1.1, r6, x.7
kpreg 1.1, r7, x.8
kpreg 2.1, r0, x.9
kpreg 2.1, r1, x.a
kpreg 2.1, r2, x.b
kpreg 2.1, r3, x.c
kpreg 2.1, r4, x.d
kpreg 2.1, r5, x.e
kpreg 2.1, r6, x.f
kpreg 2.1, r7, x.10
reg pc, x.4000
reg ivtp, x.4000
reg sp, x.9000
! kraj inicijalizacije

!resenje
!glavni program
org x.4000
!postavljanje IV tabele
ldimm x.200, r0
mvrir r0, ivtp
ldimm x.2500, r0
stmem x.200, r0
ldimm x.3000, r0
stmem x.201, r0
ldimm x.2000, r0
stmem x.202, r0
ldimm x.1500, r0
stmem x.203, r0
ldimm x.1000, r0
stmem x.204, r0
ldimm x.500, r0
stmem x.205, r0
!inicijalizacija entry registara
ldimm x.0, r0
stmem x.f042, r0
ldimm x.1, r0
stmem x.f0c2, r0
ldimm x.2, r0
stmem x.f002, r0
ldimm x.3, r0
stmem x.f202, r0
ldimm x.4, r0
stmem x.f142, r0
ldimm x.5, r0
stmem x.f102, r0
!Ucitavanje nizova A i B
!Niz A se ucitava sa KP1.1 i smesta od pozicije 5000h, proverava se Ready bit
ldimm x.5000, ra !ra je pokazivac na prvi element niza A

!Niz B se ucitava sa KP2.1 i smesta od pozicije 6000h, proverava se Ready bit
ldimm x.6000, rb !rb je pokazivac na drugi element niza B
ldimm x.8, r3 !Niz A i niz B imaju jednak broj elemenata, ovo je brojac
ldimm x.5, r0 !Upisujemo vrednost 5h u Control Register: nivo=0, start=1, enable=0, ulaz=1
stmem x.f100, r0 !upis 5h u Control Register KP1.1, pokretanje PER1
stmem x.f200, r0 !upis 5h u Control Register KP2.1, pokretanje PER2
ldimm x.1, r4 !maska za Ready bit
radi: !ispitivanje Ready bita za KP1.1 i KP2.1
	LoopA:	ldmem x.f101, r5 !upis Status Register u r5 za KP1.1
	      	tst r4, r5 !proveri Ready bit, tst radi isto sto i and samo bez upisa
	       	beql LoopA !ako je ready=0, vrti se i cekaj
		!Ready bit je ipak 1
		ldmem x.f103, r5 !iz DR KP1.1 ucitaj podatak u r5
		stri[ra], r5 !primljeni podatak iz r5 prebaci na adresu na koju upucuje ra          	
		inc ra !inkrementiraj adresu pokazivaca za unos sledeceg podatka
	LoopB:
		ldmem x.f201, r5 !upis Status Register u r5 za KP2.1
		tst r4, r5 !proveri Ready bit, tst radi isto sto i and samo bez upisa
		beql LoopB !ako je ready=0, vrti se i cekaj
		!Ready bit je ipak 1
		ldmem x.f203, r5 !iz DR KP2.1 ucitaj podatak u r5
		stri[rb], r5 !primljeni podatak iz r5 prebaci na adresu na koju upucuje rb
		inc rb !inkrementiraj adresu pokazivaca za unos sledeceg podatka
	dec r3 !dekrementiraj brojac, jer smo jedan podatak vec ucitali
	bneq radi !vrati se i ponovi postupak za 2. element oba niza
!iskljuci obe periferije
clr r0
stmem x.f100, r0 !u kontrolni registar KP1.1 upisi sve nule
stmem x.f200, r0 !u kontrolni registar KP2.1 upisi sve nule

!Oba niza su ucitana, sada sledi obrada
clr r4

!priprema steka i poziv potprograma int sumAll(int* arr1, int* arr2, int n)
ldimm x.8, r4
push r4
ldimm x.6000, r4
push r4
ldimm x.5000, r4
push r4

jsr sumAll

pop rc
pop rc
pop rc !sa steka su skinuta 3 argumenta

clr rc

stmem x.9999, r0 !rezultat funkcije sumAll se cuva iz r0 na mem.lokaciju 9999h
!inicijalizacija DMA1.4 uredjaja
ldimm x.8, r0 !koliko podataka treba preneti, to je velicina niza B, 8h
stmem x.f0c4, r0 !upis r0 u count registar na adresi F0C4h
ldimm x.6100, r0 !adresa od koje se smestaju podaci u memoriju
stmem x.f0c6, r0 !upis u destinacioni addresni regisar AR2 DMA1.4
ldimm x.6000, r0 !adresa sa koje se kopira niz B
stmem x.f0c5, r0 !upis u izvorisni adresni registar AR1 DMA1.4
ldimm x.1, r0 !upis broja ulaza u IV tabelu za DMA1.4 u r0
stmem x.f0c2, r0 !prenos r0 u entry registar za DMA1.4 koji cuva broj ulaza u IV tabelu
clr r0 !pocetna vrednost semafora je 0
stmem x.4400, r0 !odabrana slobodna lokacija x.4400 da cuva vrednost semafora, mogao je i registar neki
ldimm x.be, r0
stmem x.f0c0, r0
!ceka se da DMA1.4 zavrsi slanje
ldimm x.1, r1 ! u r1 upisuje 1 za testiranje semafora
wait1:    ldmem x.4400, r0 !cita se vrednost semafora sa odabrane lokacije 4400h i smesta u r0
	cmp r1, r0 !ako semafor nije postao 1, vec je i dalje 0
	bneq wait1 !vrati se na wait1 i cekaj

!inicijalizacija DMA1.1 uredjaja
ldimm x.8, r0 !koliko podataka treba poslati iz niza A na DMA1.1
stmem x.f004, r0 !upis r0 u Count registar na adresi F004h
ldimm x.5000, r0 !adresa odakle se prenose podaci iz niza A
stmem x.f005, r0 !upis u izvornisni adresni registar AR1 DMA1.1
ldimm x.2, r0 !broj ulaza u IV tabelu za DMA1.1 u r0
stmem x.f002, r0 !prenos r0 u entry registar za DMA1.1 koji cuva broj ulaza u IV tabelu
clr r0 !pocetna vrednost semafora je 0
stmem x.4400, r0 !odabrana slobodna lokacija x.4400 da cuva vrednost semafora, mogao je i registar neki
ldimm x.AE, r0
stmem x.f000, r0
!ceka se da DMA1.1 zavrsi slanje
ldimm x.1, r1 !u r1 upisuje 1 za testiranje semafora
wait2:	ldmem x.4400, r0 !cita se vrednost semafora sa odabrane lokacije 4400h i smesta u r0
	cmp r1, r0 !ako semafor nije postao1, vec je i dalje 0
	bneq wait2 !vrati se na wait2 i cekaj

!inicijalizacija DMA1.2 uredjaja
ldimm x.1, r0 !koliko podataka treba poslati iz memorije na DMA1.2
stmem x.f044, r0 !upis r0 u Count registar F044h
ldimm x.9999, r0 !adresa odakle se prenose podaci na DMA1.2
stmem x.f045, r0 !upis u izvorisni adresni registar AR1 DMA1.2
ldimm x.0, r0 !broj ulaza u IV tabelu za DMA1.2 u r0
stmem x.f042, r0 !prenos r0 u entry registar za DMA1.2 koji cuva broj ulaza u IV tabelu
clr r0 !pocetna vrednost semafora je 0
stmem x.4400, r0 !odabrana slobodna lokaciija x.4400 da cuva vrednost semafora, mogao je i registar neki
ldimm x.0E, r0
stmem x.f040, r0
!ceka se da DMA1.2 zavrsi slanje
ldimm x.1, r1 !u r1 upisuje 1 za testiranje semafora
wait3:	ldmem x.4400, r0 !cita se vrednost smeafora sa odabrane lokacija 4400h i smesta u r0
	cmp r1, r0 !ako semafor nije postao1, vec je i dalje 0
	bneq wait3 !vrati se na wait3 i cekaj 
halt

sumAll:
push r5 ! r5 se koristi kao bazni regisar
mvrpl r5, sp ! sp se cuva u r5. Na steku sada imamo r5, retPc, arr1, arr2, n

push r1 !koristi se r1
push r2 !koristi se r2
push r3 !koristi se r3
push r6 !koristi se r5
push r7 !koristi se r6
ldrid [r5]x.2,r1  !r5+2 je adresa na kojoj se nalazi argument arr1, r1=arr1
ldrid [r5]x.3,r2  !r5+3 je adresa na kojoj se nalazi argument arr2, r2=arr2
ldrid [r5]x.4,r3  !r5+4 je adresa na kojoj se nalazi argument n, r3=n
clr r0 !r0 je registar u kome cemo cuvati zbir trazenih n elemenata i preko koga se vraca rezultat
sabiraj:
	ldrid [r1]x.0, r6
	ldrid [r2]x.0, r7
	add r0, r0, r6
	add r0, r0, r7
	inc r1	!prelazi se na sledeci element niza A
	inc r2	!prelazi se na sledeci element niza B
	dec r3	!smanjuje se brojac preostalih elemenata za sabiranje
	!izlaz iz funkcije, u obrnutom poretku skidamo registre
	bneq sabiraj
zavrsiSabiranje:!sabrali smo sve trazene elemente
!u obrnutom poretku skidamo registre sa steka nego sto su stavljani na stek
	pop r7
	pop r6
	pop r3
	pop r2
	pop r1
	pop r5
	rts

!prek. rutina za DMA1.4
org x.3000
push r0 !r0 se koristi pa se njegova vrednost cuva na steku
ldimm x.1, r0 !upis 1h za semafor u r0
stmem x.4400, r0 !postavljanje semafora na adresu koja se ne koristi
clr r0 !0h u r0 koji ce sluziti za iskljucivanje DMA1.4 uredjaja
stmem x.f0c0, r0 !upis r0 = 0h u kontrolni registar DMA1.4 na adresi F0C0h.
pop r0 !restauracija stare vrednosti r0 sa vrha steka
rti !povratak iz prekidne rutine

!prek. rutina za DMA1.1
org x.2000
push r0 !r0 se koristi pa se njegova vrednost cuva na stekku
ldimm x.1, r0 !upis 1h za semafor u r0
stmem x.4400, r0 !postavljanje semafora na adresu koja se ne koristi
clr r0! 0h u r0 koji ce sluziti za iskljucivanje DMA1.1 uredjaja
stmem x.f000, r0 !upis r0 = 0h u kontrolni registar D1.1 na adresi F000h.
pop r0 !restauracija stare vrednosti r0 sa vrha steka
rti !povratak iz prekidne rutine

!prek. rutina za DMA1.2
org x.2500
push r0 !r0 se koristi pa se njegova vrednost cuva na steku
ldimm x.1, r0 !upis 1h za semafor u r0
stmem x.4400, r0 !postavljanje semafora na adresu koja se ne koristi
clr r0 ! 0h u r0 koji ce sluziti za iskljucivanje DMA1.2 uredjaja
stmem x.f040, r0 !upis r0 = 0h u kontrolni registar D1.2 na adresi F040h.
pop r0 !restauracija stare vrednosti r0 sa vrha steka
rti !povratak iz prekidne rutine