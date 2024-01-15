# Calculatrice VHDL 

**Calculatrice FPGA avec Mode Signé**

Projet VHDL réalisé par Leopold Rombaut, Victor Ratti, Tristan Querton, et Matia Cilly, sous la supervision des professeurs Mr. Chollet et Mr. Schneider, à l'ECE Paris - Lyon.

La calculatrice développée est une version simplifiée des calculatrices du marché. Elle peut effectuer des additions et multiplications avec des opérandes saisies via une télécommande infrarouge. Le résultat est affiché sur les afficheurs de la carte, accompagné d'un signal sonore et d'une représentation binaire sur des LEDs externes.

La calculatrice peut également utiliser un composant externe, l'additionneur à retenue anticipée 74LS283L. Un mode signé permet à l'utilisateur de réaliser des opérations avec des nombres positifs et négatifs, représentés par des LEDs intégrées à la carte.

Ce projet a été entièrement réalisé en VHDL, exploitant les capacités de la carte FPGA DE10-Lite d'Intel.

**Sources :**
- Chaine YouTube de BenEater: [BenEater YouTube](https://www.youtube.com/channel/UCS0N5baNlQWJCUrhCEo8WlA)
- Datasheet du 74LS283 : [74LS283 Datasheet](https://mil.ufl.edu/4712/docs/sn74ls283rev5.pdf)
- Guide VHDL : [VHDL Reference](https://www.ics.uci.edu/~jmoorkan/vhdlref/)
- Module de réception IR : [IR Remote Control](https://www.circuitvalley.com/2013/09/nec-protocol-ir-infrared-remote-control.html)
- Cours de VHDL S3 - ECE Paris : [Cours VHDL](https://pedago-ece.campusonline.me/course/view.php?id=5882ING2)
