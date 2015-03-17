/*
    Fionan Haralddottir
    Code being reworked to be more turing-like, only the old version is currently working.
*/
String src_code;
Clock clock;
TMRenderer turing_machine_renderer;

//Change this variable to change the speed of the turing machine
float actions_per_second = 4;

void setup() {
    rectMode(CENTER);
    size((int)(displayWidth * 0.925), (int)(displayHeight * 0.925),P3D);
    clock = new Clock();
    TMProgram program = (new TMParser(loadFileAsString(dataPath("busy_beaver.tmd")))).parse();
    TMachine turing_machine = new TMachine(program);
    turing_machine_renderer = new TMRenderer(turing_machine, actions_per_second, width/2, height/2, width, 15);
    //while (!turing_machine.halted) turing_machine.step();
}

void draw() {
    clock.update(1);
    background(255);
    turing_machine_renderer.update(clock);
    turing_machine_renderer.display(clock);
    fill(0);
}

String loadFileAsString(String path) {
    String[] str_arr = loadStrings(path);
    String str = "";
    for (int i = 0; i < str_arr.length; i++) str += str_arr[i] + "\n";
    return str;
}
