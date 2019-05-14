class Example {
   static void main(String[] args) {
      int count = 0;
      println("while循环语句：");
      while(count<5) {
         println(count);
         count++;
      }

      println("for循环语句：");
      for(int i=0;i<5;i++) {
         println(i);
      }

      println("for-in循环语句：");
      int[] array = [0,1,2,3]; 
      for(int i in array) { 
         println(i); 
      } 

      println("for-in循环范围：");
      for(int i in 1..5) {
         println(i);
      }
   }
}