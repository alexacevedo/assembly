; ************************************************************
; program: base.pep
; ************************************************************

         STRO    bienvenu,d  ; message de bienvenue
         STRO    expl1,d     ; message de ce que doit faire le programme
         STRO    expl2,d     ; message d'explication 
debut:   STRO    demande,d   ; le nombre a convertir demande
         LDA     0,i         ; initialisation a 0 des variables
         STA     nombre,d
         STA     nbcharn,d
         STA     nbchar,d
         STA     compoint,d
         STBYTEA caract,d        
lire:    CHARI   caract,d    ;lecture des caracteres
         LDBYTEA caract,d    ;analyse du caract�re lu
         CPA     10,i        ;caractere enter ?
         BREQ    finlire     ;si oui, on termine
;
;        la construction du nombre � convertir
;
         LDX     nombre,d    ;inutile de multiplier si le nombre = 0
         BREQ    pasmult     
         ASLX                ; * 2
         BRV     d�borde     
         ASLX                ; * 4
         BRV     d�borde     
         ADDX    nombre,d    ; * 5
         BRV     d�borde     
         ASLX                ; * 10
         BRV     deborde     
         STX     nombre,d           
;
;        continuation de l'analyse du caractere lu
;
pasmult: CPA     '+',i         ;determiner si le nombre est positif
         BREQ    symbole       
         CPA     '-',i         ;determiner si le nombre est negatif
         BREQ    symbole       
         CPA     '.',i         ;determiner le choix de terminer
         BREQ    point         
         CPA     '0',i         ;determiner si le caractere lu est inferierieur a 0       
         BRLT    pasnombr    
         CPA     '9',i         ;determiner si le caract�re lu est superieur a 9       
         BRGT    pasnombr   
         SUBA    '0',i         ;transformation du caract�re ASCII en decimal
         ADDA    nombre,d    
         BRV     deborde     
         STA     nombre,d    
         LDA     nbcharn,d     ;un caractere numerique lu de plus
         ADDA    1,i         
         STA     nbcharn,d  
         BR      lire        
finlire: LDA     compoint,d
         CPA     1,i         
         BREQ    choix     ;choix de terminer le programme
         BRGT    erreur
         LDA     nbchar,d
         BRNE    debut
         LDA     nbcharn,d   ;avons-nous au moins un caractere numerique ?
         BREQ    vide
         CPA     7,i
         BRGE    erreur      ;l'entree a 7 caracteres ou plus 
         BR      entete      ;affichage de la entete de la reponse  
reponse: LDA     0,i
         LDA     nombre,i
         STA     nbnegati,d  
         LDA     0,i
         LDBYTEA signe,d
         CPA     '-',i
         BREQ    nbneg 
         CHARO   '+',i
         LDA     0,i
         LDA     nombre,i
         DECO    nombre,d
calcul:  CHARO   '\t',i
         BR      calbinar    ; on commence la convertion en binaire   
suite1:  BR      caloctal    ; on commance la convertion en octal
suite2:  BR      caldec      ; on commance la convertion en d�cimal
suite3:  BR      calhex      ; on commance la convertion en hexad�cimal
suite4:  BR      debut       ; on recommence le processus
terminer:LDA     nbcharn,d   ;avons-nous au moins un caractere numerique ?
         BREQ    fnormal
         BRNE    pasnombr              
vide:    STRO    msgerreu,d   ;seulement le caractere enter a ete entre
         LDA     0,i
         BR      debut        
pasnombr:STRO    msgerreu,d  ;caractere non compris entre 0 et 9
         LDA     nbchar,d    ;un caractere non num�rique lu de plus
         ADDA    1,i         
         STA     nbchar,d  
         LDA     0,i
         CHARI   caract,d
         LDBYTEA caract,d 
         CPA     10,i        ;caractere enter ?
         BREQ    finlire
         BRNE    vider
; 
;se debarrasser de la entree
;
vider:   LDA     0,i
         CHARI   caract,d
         LDBYTEA caract,d 
         CPA     10,i        ;caractere enter ?
         BREQ    debut
         BRNE    vider
;
;determiner si l'entree des symboles  +  et  -  est invalide
;
symbole: LDA     nbcharn,d   
         BRNE    invalide
         LDA     nbchar,d
         BRNE    invalide
         LDA     nbcharn,d
         BREQ    signes
         LDA     nbchar,d
         BREQ    signes
; 
; on conserve le signe du nombre a convertir
;
signes:  LDBYTEA caract,d
         STBYTEA signe,d     
         BR      lire
;
;traitement du caratere point
;
point:   LDA     compoint, d
         ADDA    1,i
         STA     compoint,d
         BR      lire
;
;determiner si on termine
;
choix:   LDA     0,i
         LDA     nbcharn,d
         CPA     0,i
         BREQ    fnormal
         BRNE    erreur
;
;calcul du nombre binaire
;
calbinar:LDA     0, i
         STA     limite,d 
         LDA     0,i
         LDBYTEA signe,d
         CPA     '-',i       ;determiner si le nombre est negatif 
         BREQ    bneg
         BRNE    bpos
bneg:    LDA     0,i         ;traitement avec le nombre negatif
         LDA     nbnegati,d
         BR      boucle       
bpos:    LDA     nombre,d    ;traitement avec le nombre positif    
         BR      boucle               
boucle:  LDX     limite, d   
         CPX     16, i       
         BREQ    sortieb
         CPX     0,i
         BRNE    result
         BREQ    decale   
result:  LDA     resultat,d    
decale:  ASLA                ;decalage ver la gauche 
         STA     resultat, d   
si:      MOVFLGA             
         BRC     sino        ;SI C == 1 
         DECO    0, i        ;affiche 0
         LDA     limite, d    
         ADDA    1, i        
         STA     limite, d    
         BR      boucle       
sino:    DECO    1, i        ;affiche 1       
         LDA     limite, d    
         ADDA    1, i        
         STA     limite, d    
         BR      boucle        
sortieb: CHARO   '\t',i
         BR      suite1
;
;calcul du nombre octal
;
caloctal:LDA     0, i
         STA     limite,d 
         LDA     0,i
         LDBYTEA signe,d
         CPA     '-',i       ;determiner si le nombre est negatif
         BREQ    oneg
         BRNE    opos
oneg:    LDA     0,i         ;traitement avec le nombre negatif
         LDA     nbnegati,d
         BR      caloct       
opos:    LDA     nombre,d    ;traitement avec le nombre positif    
         BR      caloct 
caloct:  STA     nom,d
         LDA     0, i
         STA     limitoct,d 
         LDA     0,i
         STA     retoct,d
         LDA     nom, d 
         ASLA                ;decalage ver la gauche 
         STA     nom, d 
         MOVFLGA                     
         STA     retoct,d
         LDA     retoct,d
         BR      verif0 
con0:    DECO    retoct, d   ;affiche retenue  
boucloct:LDA     limitoct, d ;
         CPA     5, i 
         BREQ    sortieo 
         LDA     0,i
         STA     retoct,d        
         LDA     nom, d 
         ASLA                ;decalage ver la gauche
         STA     nom, d 
         MOVFLGA              
         STA     retoct,d
         LDA     retoct,d
         BR      verifoc1
con1:    ASLA                ; *2 
         STA     chiffoct,d 
         LDA     nom, d 
         ASLA                ;decalage ver la gauche
         STA     nom, d 
         MOVFLGA                  
         STA     retoct,d 
         LDA     retoct,d
         BR      verifoc2
con2:    ADDA    chiffoct,d  ; + retenu 
         STA     chiffoct,d     
         LDA     chiffoct,d
         ASLA                ; *2 
         STA     chiffoct,d  
         LDA     nom, d 
         ASLA                ;decalage ver la gauche
         STA     nom, d 
         MOVFLGA                  
         STA     retoct,d
         LDA     retoct,d
         BR      verifoc3        
con3:    ADDA    chiffoct,d     ; + retenu  
         STA     resultoc,d 
         DECO    resultoc, d    ; dont le resultat   
con4:    LDA     limitoct, d 
         ADDA    1, i 
         STA     limitoct, d 
         BR      boucloct
verif0:  CPA     1,i
         BRLE    con0
         ASRA
         MOVFLGA
         STA     retoct,d
         BR      verif0
verifoc1:CPA     1,i
         BRLE    con1
         ASRA
         MOVFLGA
         BR      verifoc1
verifoc2:CPA     1,i
         BRLE    con2
         ASRA
         MOVFLGA
         BR      verifoc2
verifoc3:CPA     1,i
         BRLE    con3
         ASRA
         MOVFLGA
         BR      verifoc3
sortieo: CHARO   '\t',i    
         BR      suite2
;
;calcul du nombre decimal
; 
caldec:  LDA     0,i
         LDBYTEA signe,d
         CPA     '-',i
         BREQ    affnbneg 
affpos:  CHARO   '+',i 
         LDA     0,i
         STBYTEA signe,d          
         LDA     nombre,d
compare: CPA     10000,i     ;traitement avec le nombre positif
         BRLT    add1fois
         BRGT    affnb
add1fois:CHARO   '0',i
         CPA     1000,i
         BRLT    add2fois
         BRGT    affnb
add2fois:CHARO   '0',i
         CPA     100,i
         BRLT    add3fois
         BRGT    affnb
add3fois:CHARO   '0',i
         CPA     10,i
         BRLT    add4fois
         BRGT    affnb
add4fois:CHARO   '0',i
         BR      affnb
affnb:   DECO    nombre,d
         CHARO   '\t',i 
         BR      suite3
affnbneg:CHARO   '-',i
         LDA     nbnegati,d 
comparen:CPA     -10000,i    ;traitement avec le nombre negatif
         BRGT    ad1fois
         BRLT    affnbn
ad1fois: CHARO   '0',i
         CPA     -1000,i
         BRGT    ad2fois
         BRLT    affnbn
ad2fois:CHARO   '0',i
         CPA     -100,i
         BRGT    ad3fois
         BRLT    affnbn
ad3fois:CHARO   '0',i
         CPA     -10,i
         BRGT    ad4fois
         BRLT    affnbn
ad4fois:CHARO   '0',i
         BR      affnbn
affnbn:  DECO    nombre,d
         CHARO   '\t',i 
         BR      suite3
;
;calcul du nombre hexadecimal
;
calhex:  LDA     0, i
         STA     limithex,d
         LDA     0,i
         LDBYTEA signe,d
         CPA     '-',i
         BREQ    hneg
         BRNE    hpos
hneg:    LDA     0,i
         LDA     nbnegati,d
         BR      cont0       
hpos:    LDA     nombre,d    
         BR      cont0           
cont0:   STA     nomh,d                 
boucl:   LDA     limithex, d 
         CPA     4, i 
         BREQ    finhex 
         LDA     0,i
         STA     retenu,d        
         LDA     nomh, d 
         ASLA                ;decalage ver la gauche
         STA     nomh, d 
         MOVFLGA                      
         STA     retenu,d
         LDA     retenu,d
         BR      verif1
cont1:   ASLA                ; *2 
         STA     chiff,d 
         LDA     nomh, d 
         ASLA                ;decalage ver la gauche
         STA     nomh, d 
         MOVFLGA                  
         STA     retenu,d
         LDA     retenu,d
         BR      verif2
cont2:   ADDA    chiff,d  ; + retenu 
         STA     chiff,d     
         LDA     chiff,d
         ASLA    ; *2 
         STA     chiff,d  
         LDA     nomh, d 
         ASLA               ;decalage ver la gauche
         STA     nomh, d 
         MOVFLGA                  
         STA     retenu,d
         LDA     retenu,d
         BR      verif3        
cont3:   ADDA    chiff,d     ; + retenu 
         STA     chiff,d
         LDA     chiff,d
         ASLA                ; *2
         STA     chiff,d
         LDA     nomh, d ;
         ASLA                ;decalage ver la gauche
         STA     nomh, d 
         MOVFLGA                  
         STA     retenu,d
         LDA     retenu,d
         BR      verif4
cont4:   ADDA    chiff,d     ; + retenu
         STA     reshex,d 
         CPA     9,i
         BRGT    affhex
         DECO    reshex, d 
cont5:   LDA     limithex, d 
         ADDA    1, i 
         STA     limithex, d 
         BR      boucl 
verif1:  CPA     1,i 
         BRLE    cont1
         ASRA
         MOVFLGA
         BR      verif1
verif2:  CPA     1,i
         BRLE    cont2
         ASRA
         MOVFLGA
         BR      verif2
verif3:  CPA     1,i
         BRLE    cont3
         ASRA
         MOVFLGA
         BR      verif3
verif4:  CPA     1,i
         BRLE    cont4
         ASRA
         MOVFLGA
         BR      verif4
affhex:  CPA     10,i        ; A = 10
         BRNE    B    
         CHARO   'A',i
         BR      cont5
B:       CPA     11,i        ; B = 11
         BRNE    C    
         CHARO   'B',i
         BR      cont5
C:       CPA     12,i        ; C = 12
         BRNE    D    
         CHARO   'C',i
         BR      cont5
D:       CPA     13,i        ; D = 13
         BRNE    E    
         CHARO   'D',i
         BR      cont5
E:       CPA     14,i        ; E = 14
         BRNE    F    
         CHARO   'E',i
         BR      cont5
F:       CHARO   'F',i       ; F = 15
         BR      cont5
finhex:  BR      suite4         
invalide:STRO    msgerreu,d  ;l'entree des symboles  +  et  -  est invalide
         BR      vider     
erreur:  STRO    msgerreu,d  ;l'entr�e a 7 caract�res ou plus 
         BR      debut                         
deborde: STRO    msgerreu,d  ;nombre > 32767
         BR      vider
entete:  STRO    tete,d 
         BR      reponse
nbneg:   LDA     0,i         ;traitement avec le nombre negatif
         LDA     nombre,d
         NEGA
         STA     nbnegati,d
         DECO    nbnegati,d
         BR      calcul
fnormal: STRO    normale,d   ;fin normale du programme
         BR      fin
fin:     STOP 
;                         
bienvenu:.ASCII  "Bienvenue au programme Les BASES !!!\x00"
expl1:   .ASCII  "\n\nCe programme sert a convertir un nombre decimal en nombre binaire"
         .ASCII  ", octal et hexadecimal. Tapez le caractere de point pour terminer le programme."
         .BYTE    0
expl2:   .ASCII  "\n\nAttention! Le nombre a convertir :\n\n"
         .ASCII  "-doit etre compose par chiffres \n\n"
         .ASCII  "-doit avoir maximum 6 caracteres\n\n"
         .ASCII  "-doit etre compris entre - 32 768 et + 32 767\n\n"
         .BYTE    0
demande: .ASCII  "\n\nVeillez entrez un nombre d�cimal (�.� - pour terminer): \x00"
msgerreu:.ASCII  "\nEntree invalide.\n\n"
         .BYTE   0                                      
normale: .ASCII  "\n\nFin normale du programme."
         .BYTE   0 
t�te:    .ASCII  "\nnombre\tbinaire         \toctal \tdecimal\thexadecimal\n" 
         .BYTE   0
;       
nombre:    .block 2           ; #2d
nbnegati:  .block 2           ; #2d
compoint:  .block 2           ; #2d
resultat:  .block 2           ; #2d  
nbcharn:   .block 2           ; #2d
nbchar:    .block 2           ; #2d
caract:    .block 1           ; #1h
signe:     .block 1           ; #1h
limite:    .BLOCK  2          ;
flag:      .BLOCK  2          ;C flag
retenu:    .block 2           ; #2d
chiff:     .block 2           ; #2d 
reshex:    .block 2           ; #2d 
limithex:  .block 2           ; #2d 
nom:       .block 2           ; #2d
nomh:      .block 2           ; #2d
retoct:    .block 2           ; #2d
chiffoct:  .block 2           ; #2d 
resultoc:  .block 2           ; #2d 
limitoct:  .block 2           ; #2d 
           .END 
