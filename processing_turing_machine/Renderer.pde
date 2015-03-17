/*
    Fionan Haralddottir
    Turing Machine in Processing
    March 2015
*/

class TMRenderer {
    TMachine turing_machine;         //The turing machine that the renderer manages and displays the state of
    float    actions_per_second;     //The number of steps performed each second
    float    time_until_next_action; //The time until the next action
    float    x;                      //The x-coordinate to display the head of the turing machine
    float    y;                      //The y-coordinate to display the head of the turing machine
    float    display_width;          //The width of the turing machine display, where the tape cuts off.
    float    size;                   //The size used for drawing the head, tape segments etc. of the machine
    int      previous_tape_index;    //The last index of the turing machine

    TMRenderer(TMachine turing_machine, float actions_per_second, float x, float y, float display_width, float size) {
        this.turing_machine         = turing_machine;                 //Assign the turing machine
        this.actions_per_second     = actions_per_second;             //Set the actions per second
        this.time_until_next_action = 0;                              //Set the time until the next action to 0
        this.x                      = x;                              //Set the x coordinate
        this.y                      = y;                              //Set the y coordinate
        this.display_width          = display_width;                  //Set the display width
        this.size                   = size;                           //Set the size
        this.previous_tape_index    = this.turing_machine.tape_index; //Set the previous tape index to the turing machine's current tape index
    }


    void update(Clock clock) {
        /*
            Update the state of the turing machine
        */
        this.doSteps(clock);
    }

    void doSteps(Clock clock) {
        /*
            Do the number of steps possible in the time that
            has passed.
        */
        if (!this.turing_machine.halted) {
            this.time_until_next_action -= clock.interval();
            while (this.time_until_next_action <= 0.0 && !this.turing_machine.halted) {
                this.previous_tape_index = this.turing_machine.tape_index;
                this.turing_machine.step();
                this.time_until_next_action += (1.0/this.actions_per_second);
            }
        }
    }

    void display(Clock clock) {
        pushMatrix();
        translate(this.x,this.y);
        this.displayHead(clock);
        this.displayTape(clock);
        this.displayStateDetails(clock);
        popMatrix();
    }

    void displayHead(Clock clock) {
        /*
            Display the head of the turing machine
        */
        //Draw a triangle pointing to where the turing machine's head is on the tape.
        triangle(-(this.size/2.0),0,0,this.size,this.size,0);
    }

    void displayTape(Clock clock) {
        /*
            Display the tape the turing machine is working on.
        */
        pushMatrix();
        translate(0,this.size);
        int starting_index = this.turing_machine.tape_index             //Use the renderer's current index as the centre
                            - (int)((this.display_width/this.size)/2);  //calculate half the number of tape symbols that can be displayed and subtract this from the centre for a most-left starting point.
        int ending_index = starting_index + (int)(this.display_width/this.size);
        for (int i = starting_index; i < ending_index; i++) {
            pushMatrix();
            translate();
            popMatrix();
        }
        popMatrix();
    }

    void displayStateDetails(Clock clock) {

    }
}

class Clock{
    //Clock class, for measuring intervals between updates.
    float previousTime; //the time of the last frame
    float presentTime; //the time of the current frame
    boolean disabled;
    Clock() {
        this.disabled = false;
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

    void update() {
        this.update(1);
    }

    void update(float multiplier) {
        if (!this.disabled) {
            this.previousTime = this.presentTime;
            this.presentTime = millis()/1000.0 * multiplier;
        }
        else {
            this.presentTime = millis()/1000.0 * multiplier;
            this.previousTime = presentTime;
        }
    }

    void toggle() {
        this.disabled = !this.disabled;
    }
}
