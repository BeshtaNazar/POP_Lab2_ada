with Ada.Text_IO; use Ada.Text_IO;
procedure Main is

   dim : constant integer := 100000;
   thread_num : constant integer := 6;

   final_min : Integer :=dim;
   index : Integer := 0;

   arr : array(1..dim) of integer;

   procedure Init_Arr is
   begin
      for i in 1..dim loop
         arr(i) := i;
      end loop;
   end Init_Arr;

   function part_min(start_index, finish_index : in integer) return Integer is
      min : integer := dim;
   begin
      for i in start_index..finish_index loop
         if arr(i)<min then
            min := arr(i);
         end if;
      end loop;
      return min;
   end part_min;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_min(min : in Integer);
      entry get_min(min : out Integer);
   private
      tasks_count : Integer := 0;
      part_min : Integer := dim;
   end part_manager;

   protected body part_manager is
      procedure set_part_min(min : in Integer) is
      begin
         if part_min>min then
            part_min := min;
         end if;

         tasks_count := tasks_count + 1;
      end set_part_min;

      entry get_min(min : out Integer) when tasks_count = thread_num is
      begin
         min := part_min;
      end get_min;

   end part_manager;

   task body starter_thread is
      min : Integer := dim;
      start_index, finish_index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      min := part_min( start_index  => start_index,
                       finish_index => finish_index);
      part_manager.set_part_min(min);
   end starter_thread;

   function parallel_min return Integer is
      min : integer := dim;
      thread : array(1..thread_num) of starter_thread;
      part_dim : integer :=dim/thread_num;
   begin
      for i in 1..thread_num loop
         if i=thread_num then
            thread(i).start( part_dim*(i-1)+1, dim);
         else
            thread(i).start( part_dim*(i-1)+1, part_dim*i);
         end if;
      end loop;
      part_manager.get_min(min);
      return min;
   end parallel_min;

begin
   Init_Arr;
   arr(dim/3):=-10;
   final_min:=parallel_min;
   for i in arr'Range loop
      if arr(i)=final_min then
         index :=i;
      end if;
   end loop;
   Put_Line(index'Img&" "&final_min'img);
end Main;
