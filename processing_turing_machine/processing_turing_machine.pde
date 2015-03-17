/*
    Fionan Haralddottir
    Code being reworked to be more turing-like, only the old version is currently working.
*/
String src_code;
TMRender turing_render;
Clock clock;

//Change this variable to change the speed of the turing machine
float operations_per_second = 14;

void setup() {
    rectMode(CENTER);
    textAlign(CENTER);
    /*
        Set up size
    */
    size(720,720);
    /*
        Set clock
    */
    clock = new Clock();
    /*
        Load source code for example 8 bit integer addition program
    */
    src_code = loadFileAsString("Add8-BitInts.tmc");
    println("loaded source code at size " + src_code.length());
    TMCompiler compiler = new TMCompiler(src_code);
    /*
        Compile program and set renderer.
    */
    turing_render = new TMRender(new TuringMachine(compiler.compile()), width/2, height/2, 20, operations_per_second, clock);
    //Set input integers here
    boolean[] tape = {/* first integer */false,false,true,true,true,false,true,false,/* second integer */false,true,true,true,false,true,true,true};
    turing_render.machine.tape = new Tape(tape);
    TMProgram program = (new TMParser(loadFileAsString(dataPath("busy_beaver.tmd")))).parse();
    TMachine turing_machine = new TMachine(program);
    while (!turing_machine.halted) turing_machine.step();
}

void draw() {
    clock.update(1);
    background(255);
    turing_render.update(clock);
    fill(0);
    text("Old version of the program, new code under Parser.pde",width/2,20);
}

String loadFileAsString(String path) {
    String[] str_arr = loadStrings(path);
    String str = "";
    for (int i = 0; i < str_arr.length; i++) str += str_arr[i] + "\n";
    return str;
}
