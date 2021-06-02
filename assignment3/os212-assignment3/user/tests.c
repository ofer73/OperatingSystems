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
    return 0;
}

int 
NFUA_test(){
    int* pages[18];
    ////-----NFU + AGING----------///////////
    printf( "--------------------NFU + AGING:----------------------\n");
    printf( "-------------allocating 16 pages-----------------\n");
    if(fork() == 0){
        for(int i = 0; i < 16; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
        
        sleep(20);

        printf("first we will access page 8 %d,\n", *pages[8]);
        sleep(2);

        printf( "-------------now access all pages except 8-----------------\n");
        for(int i = 0; i < 16; i++){
            if (i!=8)
                *pages[i] = i;
        }

        sleep(2);
        printf( "------------- creating a new page, page 8 should be paged out -----------------\n");
        pages[16] = (int*)sbrk(PGSIZE);
        
        printf( "------------- accessing page 8 -> should cause pagefault-----------------\n");
        printf("&page 8= %p contains  %d\n",pages[8],*pages[8]);
        printf("doing another sbrk for senity check  %d\n");
        pages[17] = (int*)sbrk(PGSIZE);
        printf("---------finished NFUA test!!!!----------\n");
        exit(0);

    }
    wait(0);
    return 1;
}

int
LAPA_when_all_equal(){
    int* pages[18];
    printf( "-----------------------------fork_LAPA_when_all_equal-----------------------------\n");
    if(fork() == 0){
        printf( "---------allocating and modifing 16 pages-----------\n");
        for(int i = 0; i < 16; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
        sleep(20); // we want to zero all aging counters 
                  //(avoiding problems in test logic due to unexpected contex switch )
        printf( "----------accessing all pages, starts with page[8]-------------\n");
        *pages[8] = 8;
        sleep(10);
        for(int i = 0; i < 16; i++){
            if (i!=8)
                *pages[i] = i;
        }
        sleep(5);
       
        printf( "-------create new page, page 8 need to swapout-----------\n");
        pages[16] = (int*)sbrk(PGSIZE);
        
        printf( "--------access page 8 shuld cause pagefault---------\n");
        printf("page 8 value =  %d\n",*pages[8]);
        printf("---finished LAPA_when_all_equal---\n");

        exit(0);

    }
    wait(0);
    return 0;
}

int
LAPA_paging(){
    int* pages[18];
    printf( "--------------------LAPA_paging--------------------\n");
    printf( "-------------allocating and modifing 16 pages-----------------\n");
    if(fork() == 0){
        for(int i = 0; i < 16; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
        sleep(20); // we want to zero all aging counters
        printf( "--------modifing each page 2 times except pages[8]-----------------\n");
        for(int j=0;j<2;j++){
            for(int i = 0; i < 16; i++){
                if (i!=8)
                    *pages[i] = i;
            }
            sleep(1);// to update the aging counter once
        }
       
        printf( "--------modifing page 8 once----------\n");
        *pages[8] = 8;
        printf( "-----create new page-> page 8 need to swapout------\n");
        pages[16] = (int*)sbrk(PGSIZE);
        
        printf( "-------access page 8 need to cause pagefault-------\n");
        printf("pages[8] contains  %d\n",*pages[8]);
        printf("-----finish LAPA_paging-----\n");
        exit(0);

    }
    wait(0);
    return 0;
}

int
LAPA_test_fork_copy(){
    int* pages[18];
    printf( "--------------------LAPA 3 : FORK test:----------------------\n");
    printf( "-------------allocating 16 pages for father-----------------\n");
    for(int i = 0; i < 16; i++){
            pages[i] = (int*)sbrk(PGSIZE);
            *pages[i] = i;
        }
    sleep(20);
    printf( "------------- accessing all pages 3 times except page 8-----------------\n");
        for(int j=0;j<3;j++){
            for(int i = 0; i < 16; i++){
                if (i!=8)
                    *pages[i] = i;
            }
            sleep(1);
        }

        printf( "-------------now access pages 8 only twice-----------------\n");
        *pages[8] = 8;
        *pages[8] = 8;
        sleep(1);
    if(fork() == 0){
        printf( "-------------Son: create a new page, page 8 should be paged out-----------------\n");
        pages[16] = (int*)sbrk(PGSIZE);
        
        printf( "-------------Son: now acess to page 8 should cause pagefault-----------------\n");
        printf("page 8 contains  %d\n",*pages[8]);
        exit(0);
    }

    wait(0);
    printf( "-------------Father: create a new page, page 8 should be paged out-----------------\n");
        pages[16] = (int*)sbrk(PGSIZE);
        
        printf( "-------------Father: now acess to page 8 should cause pagefault-----------------\n");
        printf("page 8 contains : %d",*pages[8]);
        
    printf("---------finished LAPA_test_fork_copy test!!!!----------\n");

    return 0;
}

int 
fork_test(){
    #ifdef SCFIFO
    return fork_SCFIFO();
    #endif

    #ifdef NFUA
    return NFUA_test();
    #endif

    #ifdef LAPA
    char wait[3];   // used to ask for input and delay between tests
    LAPA_paging();
    gets(wait,3);
    LAPA_when_all_equal();
    gets(wait,3);
    return LAPA_test_fork_copy();
    #endif
    return -1;
    
}

int malloc_and_free(){
    printf("-----------------------------malloc--------\n");

    void* a = sbrk(PGSIZE);
    void* b = malloc(PGSIZE);

    printf("-----------------------------free--------\n");
    free(a);
    free(b);
    printf("-----------------------------PASS--------\n");

    return 0;
}

int
main(int argc, char *argv[])
{
    // printf("-----------------------------sbark_and_fork-----------------------------\n");
    // sbark_and_fork();
    printf("-----------------------------fork_test-----------------------------\n");
    fork_test();
    // printf("-----------------------------malloc_and_free-----------------------------\n");
    // malloc_and_free();
    exit(0);
    return 0;
}