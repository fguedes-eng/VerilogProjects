// Code your design here
class Timer;
    int time_value;
    int max_time;

    function new(int max_time = 100, int init_value = 0);
        if (init_value > max_time || init_value < 0)
            $warning("Valor inicial excede limites de tempo!");
        else begin
            this.max_time = max_time;
            this.time_value = init_value;
        end
    endfunction

    function void set_time(int newTime);
        if (newTime > max_time)
            $warning("Valor excede tempo máximo!");
        else if (newTime < 0)
            $warning("Valor excede tempo mínimo!");
        else
            time_value = newTime;
    endfunction

    function int get_time();
        return time_value;
    endfunction

    virtual function void tick();
        if (time_value < max_time) begin
            time_value++;
        end
    endfunction
endclass

class repetitive_timer extends Timer;
    bit rollover;
    static int instances = 0;

    function new(int max_time = 100, int init_value = 0);
        if (init_value > max_time || init_value < 0)
            $warning("Valor inicial excede limites de tempo!");
        else begin
            this.max_time = max_time;
            this.time_value = init_value;
            instances++;
        end
    endfunction

    static function int get_instances();
        return instances;
    endfunction

    function void tick();
        if (time_value == max_time) begin
            time_value = 0;
            rollover = 1;
        end else begin
            time_value++;
            rollover = 0;
        end
    endfunction
endclass

class countdown_timer extends Timer;
    bit expired;
    static int instances = 0;
    int flag = 0;

    function new(int max_time = 100, int init_value = 0);
        if (init_value > max_time || init_value < 0)
            $warning("Valor inicial excede limites de tempo!");
        else begin
            this.max_time = max_time;
            this.time_value = init_value;
            instances++;
        end
    endfunction

    static function int get_instances();
        return instances;
    endfunction

    function void tick();
        if (!flag) begin
            time_value = max_time;
            flag = 1;
        end

        if (time_value > 0)
            time_value--;
        else
            expired = 1;
    endfunction
endclass

class timer_system;
    repetitive_timer t1;
    countdown_timer t2;
    Timer t3;

    function new();
        t1 = new(50, 0);
        t2 = new(50, 50);
        t3 = new();
    endfunction

    task run_system();
        repeat(55) begin
            t1.tick();
            t2.tick();
            t3.tick();
            $display("T1=%0d | T2=%0d | T3=%0d || rollover = %0d | expired = %0d", t1.get_time(), t2.get_time(), t3.get_time(), t1.rollover, t2.expired);
            #1;
        end
    endtask
endclass

module tb_timer;
    initial begin
        timer_system sys = new();
        sys.run_system();
        $display("Instâncias repetitivas: %0d", repetitive_timer::get_instances());
        $display("Instâncias regressivas: %0d", countdown_timer::get_instances());
    end
endmodule
