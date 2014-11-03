/*
    Turing machine renderer class
*/

class TMRender {
    //The machine we are rendering
    TuringMachine machine;

    //The max number of actions the machine is allowed to perform per second
    float act_per_sec;

    //coordinates on screen
    float x;
    float y;
    float unit_size;
    int last_index;
    float last_action_time;


    TMRender(TuringMachine machine, float x, float y, float size, float act_per_sec, Clock clock) {
        this.machine = new TuringMachine(machine);
        this.act_per_sec = act_per_sec;
        this.x = x;
        this.y = y;
        this.unit_size = size;
        this.last_action_time = clock.presentTime;
    }

    void update(Clock clock) {
        this.doSteps(clock);
        this.display(clock);
    }

    void doSteps(Clock clock) {
        /*
            Do all the steps we can given the time passed
        */
        //println("(tm renderer) time passed: " + (clock.presentTime - (this.last_action_time)));
        while ((clock.presentTime - (this.last_action_time) > (1000.0/(act_per_sec * 1000.0))) && !this.machine.halted) {
            //println("(tm)");
            this.last_index = this.machine.tape_index;
            this.machine.step();
            this.last_action_time += (1000.0/(act_per_sec * 1000.0));
            //println("(tm renderer) done a step");
        }
    }

    void display(Clock clock) {
        /*
            First draw tape
        */
        float x_begin = this.x; //+ (this.last_index - this.machine.tape_index) + (clock.interval(this.last_action_time) * this.unit_size);
        fill(this.machine.tape.default_state ? 0 : 255);
        for (int i = int((int(x_begin) % int(this.unit_size)) - this.unit_size); i <= width + this.unit_size; i+= this.unit_size) {
            stroke(this.machine.tape.default_state ? 255 : 0);
            rect(i, this.y + this.unit_size,this.unit_size,this.unit_size);
        }
        for (int i = -(this.machine.tape.negsize()); i < this.machine.tape.possize(); i++) {
            if (this.machine.tape.read(i)) {
                fill(0);
                stroke(255);
            }
            else {
                fill(255);
                stroke(0);
            }
            rect(x_begin + ((i - this.machine.tape_index) * this.unit_size), this.y + this.unit_size, this.unit_size, this.unit_size);
        }
        /*
            Draw machine
        */
        stroke(0);
        fill(150,20,150);
        rect(this.x,this.y,this.unit_size,this.unit_size);
        fill(0);
        textSize(this.unit_size);
        /*
            Draw text
        */
        for (int i = -this.machine.tape.negsize(); i < this.machine.tape.possize(); i++) {
            if (i % 8 == 0) {
                text(i, x_begin + ((i - this.machine.tape_index) * unit_size),this.y + (3 * this.unit_size));
                line(x_begin + ((i - this.machine.tape_index) * unit_size), this.y + unit_size,x_begin + ((i - this.machine.tape_index) * unit_size), this.y + (2 * unit_size));
            }
        }
        text(typeAsString(this.machine.currentInstruction(-1)),this.x,this.y - (2 * this.unit_size));
    }
}

/*
    Clock class borrowed from previous coursework
*/

class Clock{
    //Clock class, for measuring intervals between updates.
    float previousTime; //the time of the last frame
    float presentTime; //the time of the current frame

    Clock() {
        this.previousTime = (millis() - 1)/1000.0;
        this.presentTime = millis()/1000.0;
    }

    float interval() {
        //returns the interval between the last update and the update before that in seconds
        //this is used as the update variable in all movement functions
        return this.presentTime - this.previousTime;
    }

    float interval(float given_time) {
        return this.presentTime - given_time;
    }

    void update(float multiplyer) {
        this.previousTime = this.presentTime;
        this.presentTime = millis()/1000.0 * multiplyer;
    }
}
