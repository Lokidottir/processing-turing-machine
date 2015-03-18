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
        this.time_until_next_action = 1/actions_per_second;           //Set the time until the next action to 0
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
        if (!this.turing_machine.halted) {                   //Skip the processing if the turing machine is halted, as the program will needlessly loop
            this.time_until_next_action -= clock.interval(); //Take the time interval away from the time_until_next_action variable, acting like a countdown

            while (this.time_until_next_action <= 0.0 && !this.turing_machine.halted) { //While the countdown is in the negatives, update. also check for halting
                this.previous_tape_index = this.turing_machine.tape_index;              //Set the previous tape index as the turing machine's current tape index
                this.turing_machine.step();                                             //Step the turing machine's program
                this.time_until_next_action += (1.0/this.actions_per_second);           //Add the "seconds-per-action" to the time until the next action.
            }
        }
    }

    void display(Clock clock) {
        rectMode(CENTER);
        pushMatrix();
        translate(this.x,this.y);        //Translate to the coordinates of the turing machine
        this.displayHead(clock);         //Display the head of the turing machine
        this.displayTape(clock);         //Display the tape the machine is acting upon
        this.displayStateDetails(clock); //Display information about the turing machine's state
        popMatrix();
    }

    void displayHead(Clock clock) {
        /*
            Display the head of the turing machine
        */
        //Draw a triangle pointing to where the turing machine's head is on the tape.
        //As the head is stationary, draw a triangle poinging towards the centre.
        triangle(-(this.size/2.0),0,0,this.size,this.size/2.0,0);
    }

    void displayTape(Clock clock) {
        /*
            Display the tape the turing machine is working on.
        */
        pushMatrix();
        translate(0,this.size * 1.5);
        int bit_display_count = ceil(this.display_width/this.size);     //Calculate the number of tape segments/bits to be displayed
        int starting_index = this.turing_machine.tape_index             //Use the renderer's current index as the centre
                            - bit_display_count/2;                      //The starting point will be half the number of bits to be displayed across from the centre.

        int ending_index = starting_index + bit_display_count;          //Add the bit display count to the starting index to get the ending index.

        for (int i = starting_index; i <= ending_index; i++) {
            pushMatrix();
            float temporal_offset = this.calculateMovementOffset();     //Get the time-sensitive movement offset for animating movement
            translate(-((bit_display_count/2) * this.size)              //Translate to the calculated position to display the bit's status
                      + ((i - starting_index) * size) + temporal_offset, 0);

            fill(this.turing_machine.tape.read(i) ? 0 : 255);           //Fill black/white depending on true/false
            stroke(this.turing_machine.tape.read(i) ? 255 : 0);         //Stroke white/black depending on true/false
            rect(0,0,this.size,this.size);                              //Draw the rectangle representing the bit
            if (i % 8 == 0) {
                /*
                    Draw a marker at every 8th point indicating
                    the tape index for easier reading of tape by
                    visual observers of the tape.
                */
                stroke(0);                                              //Set the stroke to 0, so the lines are visible
                fill(0);                                                //Set the fill to 0, so the text is visible
                textSize(this.size);                                    //Set the text size
                line(0,this.size/2,0,(this.size/2) * 3);                //Draw the line from the nth box to where the text will be
                pushMatrix();
                translate(0,this.size * 2.5);                           //translate to the to-be text coordinates
                textAlign(CENTER);                                      //Set text alignment
                text(i,0,0);                                            //Output the index
                popMatrix();
            }
            popMatrix();
        }
        popMatrix();
    }

    float calculateMovementOffset() {
        return 0;
    }

    void displayStateDetails(Clock clock) {
        pushMatrix();
        translate(0,-this.size * 6); //Translate to where the text will be displayed
        textSize(this.size);         //Set the text size
        fill(0);                     //Set the fill to 0
        textAlign(LEFT);             //Set text alignment
        /*
            Render the text
        */
        text("state : " + (this.turing_machine.statenum != HALTED_STATENUM ? this.turing_machine.statenum : "Halted") + "\n" +
             "decision mode : " + this.turing_machine.decision_mode + "\n" +
             "action : " + this.decisionActionAsString() + "\n" +
             "tape index : " + this.turing_machine.tape_index
             ,0,0);
        popMatrix();
    }

    String decisionActionAsString() {
        /*
            Return a string description of the current decision state
        */
        switch (this.turing_machine.decision_state) {
            case WRITE_STATE: return "Writing";
            case MOVE_STATE:  return "Moving";
            case GOTO_STATE:  return "State transition";
            default:          return "Nullstate";
        }
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
