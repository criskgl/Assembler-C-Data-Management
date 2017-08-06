#include <stdio.h>
#include <stdlib.h>
    
//FUNCTION: printMatrix
void printMatrix(int dim,float mat[dim][dim]){
    int i = 0;
    int j = 0;
    for(i = 0; i < dim; i++){
        for(j = 0; j < dim; j++){
            printf("%g\t", mat[i][j]);//we print matrix 
        }
        printf("\n");
    }
}

//FUNCTION: C CONSTRUCTION
void minimoFloat(int dim, float matA[dim][dim], float matB[dim][dim], float matD[dim][dim]){
    //NaN 
    const unsigned All1 = ~0;
    const float qNan =  *((float*)&All1);

        int i = 0;
        int j = 0;

        for(i = 0; i < dim; i++){
            for(j = 0; j < dim; j++){

                if((matA[i][j] - matB[i][j]) > 0){    
                    matD[i][j] = matB[i][j];
                }else{
                    matD[i][j] = matA[i][j];
                }
                if(matA[i][j] != matA[i][j]){
                    matD[i][j] = -qNan;
                }
                if(matB[i][j] != matB[i][j]){
                    matD[i][j] = -qNan;
                }
            }
        }
}
//MAIN FUNCTION
int main(int argc, char const *argv[])
{
    //Variables 
    
    //NaN 
    const unsigned All1 = ~0;
    const float qNan =  *((float*)&All1);

    FILE *fpA;//Stores adress of first Matrix---->(ficheroA)
    FILE *fpB;//Stores adress of second Matrix--->(ficheroB)
    FILE *fpC;//Stores adress of third Matrix--->(ficheroC)
    FILE *fpD;//Stores adress of fourth Matrix--->(ficheroD)
    int dimension;
    //int cont = 0;
    int aux = 0;
    int k = 0;
    int lng = 0;
    char c;
    //float matrixA[dimension][dimension];
    int i, j;

    //FINDING DIMENSION...

    if(argc != 6){//Checks if the number of arguments is equal to 5 to cointinue working(Name of programs counts as one argument)
        printf("You need to type 6 parameters strictly, number of program included.\n"); 
        return -1;
    }
    //to find the lenght of the 1st parameter (dimension) and check if there are any other characters other than numbers.  
    while ((c = argv[1][lng]) != 0){  //argv[1] = "234" => argv[1][0] = 2
        if(c < 48 || c > 57){//Only allows ascii characters 0 to 9 are allowd
        printf("Only numbers are allowed/n");
        return -1;
        }    
        lng++;
    }
    //the value of the argument entered is obtained in its decimal value. 
    while(k<lng){ 
        int exponent = 1;
        for (int i = 1; i < (lng - k); i++){//a weight of 10^exponent is given to each character found.
            exponent = exponent * 10;
        }
        aux = aux + (argv[1][k]-'0') * exponent;
        k++;
    }
    
    dimension = aux;//the value found is moved to the variable "dimension" for its following use reading the matrix A and B.
    if (dimension <= 0){
        printf("Dimension must be an integer greater than 0\n");
        return -1;
    }
    printf("\n");
    printf("THE DIMENSION IS ---->  %d\n", dimension);
    printf("\n");
    printf("INTRODUCED MATRICES:\n");
    printf("\n");
//MATRIX VARIABLES ONCE DIMENSION IS KNWON
float matrixA[dimension][dimension], matrixB[dimension][dimension], matrixC[dimension][dimension], matrixD[dimension][dimension];


//FINDING  MATRIX FROM FIRST FILE
    fpA = fopen(argv[2], "r");//adress of argument[2] is stored in the fp variable 

    for(i = 0; i < dimension; i++){

        for(j = 0; j < dimension; j++){

            fscanf(fpA,"%g", &matrixA[i][j]); //fp variable gives the adress where our file is and stores values in matrixA[i][j]

        }

    }
    printf("MATRIX A:\n");
    printMatrix(dimension, matrixA);//we print matrixA

//FINDING MATRIX FROM SECOND FILE
    fpB = fopen(argv[3], "r");//adress of argument[3] is stored in the fp variable 

    for(i = 0; i < dimension; i++){

        for(j = 0; j < dimension; j++){

            fscanf(fpB,"%g", &matrixB[i][j]); //fp variable gives the adress where our file is and stores values in matrixB[][]

        }

    }
    printf("\n");

    printf("MATRIX B:\n");
    printMatrix(dimension, matrixB);//we print matrixB
//<><><><><><><><><><><><><><><><><><><><><><><><>MATRIX C PROCESSING<><><><><><><><><><><><><><><><><><><><><><><><><><><><>
printf("\n");
printf("MATRIX C:\n");

unsigned int *maskA;
unsigned int *maskB;

int expA, expB, mantA, mantB;

for(i = 0; i < dimension; i++){
    for(j = 0; j < dimension; j++){
        maskA = (unsigned int *) &matrixA[i][j];
        maskB = (unsigned int *) &matrixB[i][j];

        expA = *maskA & 0x7f800000;
        expB = *maskB & 0x7f800000;
        mantA = *maskA & 0x007fffff;
        mantB = *maskB & 0x007fffff;

        expA = (expA >> 23)-127;
        expB = (expB >> 23)-127;

        if(matrixA[i][j] == 0.0 && matrixB[i][j] == 0.0){//1
        matrixC[i][j] = 0.0;
        }
        else if(matrixA[i][j] == qNan || matrixB[i][j] == qNan){//2
            matrixC[i][j] = -qNan;
        }
        else if((matrixA[i][j] == (float) 1.0/0.0 || matrixA[i][j] == (float)-1.0/0.0) || (matrixB[i][j] == (float) 1.0/0.0 || matrixB[i][j] == (float) -1.0/0.0)){//3
            matrixC[i][j] = -qNan;
        }
        else if(expA == 0 && mantA != 0 && (expB == 0) && mantB != 0){//4 A:Not normalized y B:Not normalized
            matrixC[i][j] =  0.0; 
        }
        else if( ((expA == 0) && mantA != 0) && ((expB != 0) || (expB == 0 &&  mantB == 0)) ){//5:A:Not normalized y B: Normalized
            matrixC[i][j] = matrixB[i][j]; 
        }
        else if(  ((expB == 0) && mantB != 0) && ((expA != 0) || (expA == 0 &&  mantA == 0)) ){//6:B:Not normalized y A: Normalized
            matrixC[i][j] = matrixA[i][j];
        }
        else if ( ((expA != 0) || (expA == 0 &&  mantA == 0)) && ((expB != 0) || (expB == 0 &&  mantB == 0)) ){//7:Both Normalized 
            matrixC[i][j] = (matrixA[i][j] + matrixB[i][j]);
        }
        else( matrixC[i][j] = (char) 69);
        printf("%g\t", matrixC[i][j]);
    }
    printf("\n");
}
printf("\n");


//PRINT IN FILE "ficheroC.txt"
fpC = fopen(argv[4], "w");

for(i = 0; i < dimension; i++){
    for(j = 0; j < dimension; j++){
        fprintf(fpC, "%g\t\t", matrixC[i][j]);

    }
    fprintf(fpC, "\n");
}
//<><><><><><><><><><><><><><><><><><><><><><><>MATRIX D PROCESSING<><><><><><><><><><><><><><><><><><><><><><><><><><><>
minimoFloat(dimension, matrixA, matrixB, matrixD);//Calls function to build matrixD
//<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

//PRINT MATRIX D
printf("Matrix D: \n");
printMatrix(dimension, matrixD);
//PRINT IN FILE "ficheroD.txt"
fpD = fopen(argv[5], "w");

for(i = 0; i < dimension; i++){
    for(j = 0; j < dimension; j++){
        fprintf(fpD, "%g\t\t", matrixD[i][j]);

    }
    fprintf(fpD, "\n");
}

printf("\nMatrices C & D have been printed in their correspondent files \n");

printf("\nPROGRAM WORKED!!!!!\n");
//END PROGRAM
   return 0;   
}