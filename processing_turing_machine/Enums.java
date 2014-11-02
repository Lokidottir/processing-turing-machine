/*
    Instruction set enumerations
*/

enum Instruction {
    SCAN, // move a relative number of bits along the tape (+25, -2 etc.) (1 argument)
    /*
        scan +4 //move 4 along the tape
    */
    CALL, // call a specific page as you would a (1 argument)
    /*
        pgrn 7 // call the 7th page
    */
    FLIP, // flip the current bit (0 arguments)
    /*
        flip // flip the current bit
    */
    IFBIT,// if the bit at the tape is 1 then execute the lines until an ENDIF, otherwise skip (0 arguments)
    ENDIF,// end of if statement body (0 arguments)
    /*
        ifbit
        ... // do stuff
        endif
    */
    HALT, // halt the program (0 arguments)
    /*
        ...  // series of commands
        halt // end the program
        ...  // series of commands that are not executed because the program halted
    */
    SAVE, // save position on stack (0 arguments)
    /*
        ...  // series of commands that set the machine to position 6
        save // #0 now holds the value of position 6
    */
    SPOP, // pop the top stack item (0 arguments)
    /*
        save // position of value is saved to stack
        ...  // code is executed
        spop //value is popped from stack
    */
    LGIC,  // perform a logical operation on the current bit and a given registery bit (2 arguments)
    /*
        lgic or #0 //the bit at our position is OR'd with the value at the top of the stack.
    */
    NONE  // Not an instruction
    /*
        ... // valid code
        kja // invalid command, compiler error
    */
};

enum ArgType {
    REG, // registry code (relative)(#4, value of 4th-to-top item on stack)
    REL, // relative movement (+3, move 3 along the tape)
    POS, // absolute position (t5 or p6l4, tape index 5 or the 4th line of program page 6)
    OPR, // operation (and, or, xor, not)
    NUL  // no argument given
};

enum Logical {
    //Logical enumerations for logic arg types
    AND,
    OR,
    XOR,
    NOT,
    NONE
};
