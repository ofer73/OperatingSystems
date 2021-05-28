#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PGSIZE 4096
int sbark_and_fork(){
    for (int i = 0; i < 22; i++)
    {
        printf("sbrk %d\n",i);
        sbrk(4096);
    }
    // notice 6 pages swaped out
    int pid= fork();
    if (pid == 0)
    {
        printf("child sbrk\n");
        sbrk(4096);
        printf("child sbrk neg\n");
        sbrk(-4096 * 14);
        printf("child sbrk\n");
        sbrk(4096 * 4);
        sleep(5);
        exit(0);
    }
    wait(0);
    printf("test: finished test\n");
    return 0;
}
int
just_a_func(){
    printf("func\n");
    return 0;
}

int 
fork_SCFIFO(){
    char in[3];
    int* pages[18];
    ////-----SCFIFO TEST----------///////////
    printf( "--------------------SCFIFO TEST:----------------------\n");
    printf( "-------------allocating 16 pages-----------------\n");
    if(fork() == 0){
        for(int i = 0; i < 16; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
        
        printf( "-------------now add another page. page[0] should move to the file-----------------\n");
        pages[16] = (int*)sbrk(PGSIZE);
        //printf( "-------------all pte_a except the new page should be turn off-------\n");
        printf( "-------------now access to pages[1]-----------------\n");
        printf("pages[1] contains  %d\n",*pages[1]);
        printf( "-------------now add another page. page[2] should move to the file-----------------\n");
        pages[17] = (int*)sbrk(PGSIZE);
        printf( "-------------now acess to page[2] should cause pagefault-----------------\n");
        printf("pages[2] contains  %d\n",*pages[2]);
        printf("---------passed scifo test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
}

int 
fork_NFUA(){
    char in[3];
    int* pages[18];
    ////-----NFU + AGING----------///////////
    printf( "--------------------NFU + AGING:----------------------\n");
    printf( "-------------allocating 12 pages-----------------\n");
    if(fork() == 0){
        for(int i = 0; i < 13; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
        
        printf( "-------------now access all pages except pages[5]-----------------\n");
        for(int i = 0; i < 13; i++){
            if (i!=5)
                *pages[i] = i;
        }
        printf( "-------------now create a new page, pages[5] should be moved to file-----------------\n");
        pages[13] = (int*)sbrk(PGSIZE);
        
        printf( "-------------now acess to page[5] should cause pagefault-----------------\n");
        printf("pages[5] contains  %d\n",*pages[5]);
        printf("---------passed NFUA test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
    return 1;
}

int
fork_LAPA1(){
    char in[3];
    int* pages[18];
    printf( "--------------------LAPA 1:----------------------\n");
    printf( "-------------allocating 12 pages-----------------\n");
    if(fork() == 0){
        for(int i = 0; i < 16; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
        printf( "-------------now access all pages  pages[5] will be acessed first -----------------\n");
        *pages[5] = 5;
        sleep(10);
        for(int i = 0; i < 16; i++){
            if (i!=5)
                *pages[i] = i;
        }
        
       
        printf( "-------------now create a new page, pages[5] should be moved to file-----------------\n");
        pages[16] = (int*)sbrk(PGSIZE);
        
        printf( "-------------now acess to page[5] should cause pagefault-----------------\n");
        printf("pages[5] contains  %d\n",*pages[5]);
        printf("---------passed LALA 1 test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
}

int
fork_LAPA2(){
    char in[3];
    int* pages[18];
    printf( "--------------------LAPA 2:----------------------\n");
    printf( "-------------allocating 12 pages-----------------\n");
    if(fork() == 0){
        for(int i = 0; i < 12; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
        
        printf( "-------------now access all pages twice except pages[5]-----------------\n");
        for(int i = 0; i < 12; i++){
            if (i!=5)
                *pages[i] = i;
        }
        sleep(1);
        for(int i = 0; i < 12; i++){
            if (i!=5)
                *pages[i] = i;
        }
        printf( "-------------now access pages[5] once-----------------\n");
        *pages[5] = 5;
        printf( "-------------now create a new page, pages[5] should be moved to file-----------------\n");
        pages[12] = (int*)sbrk(PGSIZE);
        
        printf( "-------------now acess to page[5] should cause pagefault-----------------\n");
        printf("pages[5] contains  %d\n",*pages[5]);
        printf("---------passed LAPA 2 test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
}

int
fork_LAPA3(){
    char in[3];
    int* pages[18];
    printf( "--------------------LAPA 3 : FORK test:----------------------\n");
    printf( "-------------allocating 12 pages for father-----------------\n");
    for(int i = 0; i < 12; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
    printf( "-------------now access all pages twice except pages[5]-----------------\n");
        for(int i = 0; i < 12; i++){
            if (i!=5)
                *pages[i] = i;
        }
        sleep(1);
        for(int i = 0; i < 12; i++){
            if (i!=5)
                *pages[i] = i;
        }
        printf( "-------------now access pages[5] once-----------------\n");
        *pages[5] = 5;
    if(fork() == 0){
        printf( "-------------CHILD: create a new page, pages[5] should be moved to file-----------------\n");
        pages[14] = (int*)sbrk(PGSIZE);
        
        printf( "-------------CHILD: now acess to page[5] should cause pagefault-----------------\n");
        printf("pages[5] contains  %d\n",*pages[5]);
        exit(0);

    }
    wait(0);
    printf( "-------------FATHER: create a new page, pages[5] should be moved to file-----------------\n");
        pages[14] = (int*)sbrk(PGSIZE);
        
        printf( "-------------FATHER: now acess to page[5] should cause pagefault-----------------\n");
        printf("pages[5] contains  %d\n",*pages[5]);
        
        
   
    printf("---------passed LAPA 3 test!!!!----------\n");
    gets(in,3);
}

int 
fork_test(){
    #ifdef SCFIFO
    return fork_SCFIFO();
    #endif

    #ifdef NFUA
    return fork_NFUA();
    #endif

    #ifdef LAPA
    fork_LAPA1();
    fork_LAPA2();
    return fork_LAPA3();
    #endif
    return -1;
    
}
int
main(int argc, char *argv[])
{
    // printf("-----------------------------sbark_and_fork-----------------------------\n");
    // sbark_and_fork();
    printf("-----------------------------fork_test-----------------------------\n");
    fork_test();
    exit(0);
    return 0;
}