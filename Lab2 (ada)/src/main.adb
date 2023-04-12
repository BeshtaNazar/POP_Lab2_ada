with Ada.Text_IO; use Ada.Text_IO;
procedure Main is

   dim : constant integer := 100000;
   thread_num : constant integer := 6;


   final_index : Integer := 0;

   arr : array(1..dim) of integer;
   final_min : Integer :=2147483647;

   procedure Init_Arr is
   begin
      for i in 1..dim loop
         arr(i) := i;
      end loop;
   end Init_Arr;

   procedure part_min(start_index : in integer; finish_index : in integer; index: out Integer; min: out Integer ) is

   begin
      min := arr(start_index);
      index:=start_index;
      for i in start_index..finish_index loop
         if arr(i)<min then
            min := arr(i);
            index:=i;
         end if;
      end loop;

   end part_min;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_min(min, index : in Integer);
      entry get_min(min, index: out Integer);
   private
      tasks_count : Integer := 0;
      part_min : Integer := 2147483647;
      part_index : Integer :=0;
   end part_manager;

   protected body part_manager is
      procedure set_part_min(min, index : in Integer) is
      begin
         if part_min>min then
            part_min := min;
            part_index:= index;
         end if;

         tasks_count := tasks_count + 1;
      end set_part_min;

      entry get_min(min, index : out Integer) when tasks_count = thread_num is
      begin
         min := part_min;
         index:=part_index;
      end get_min;

   end part_manager;

   task body starter_thread is
      min : Integer := 2147483647;
      start_index, finish_index, index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      part_min(start_index, finish_index, index, min);
      part_manager.set_part_min(min, index);
   end starter_thread;

   procedure parallel_min (index, min :out Integer) is
      thread : array(1..thread_num) of starter_thread;
      part_dim : integer :=dim/thread_num;
   begin
      min  := 2147483647;
      index :=0;
      for i in 1..thread_num loop
         if i=thread_num then
            thread(i).start( part_dim*(i-1)+1, dim);
         else
            thread(i).start( part_dim*(i-1)+1, part_dim*i);
         end if;
      end loop;
      part_manager.get_min(min, index);
   end parallel_min;

begin
   Init_Arr;
   arr(dim/3):=-10;
   parallel_min(final_index, final_min);

   Put_Line(final_index'Img&" "&final_min'img);
end Main;
