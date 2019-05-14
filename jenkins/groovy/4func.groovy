class Example {
   static def PrintHello() {
      println("This is a print hello function in groovy");
   } 

   static int sum(int a, int b, int c = 10) {
      int d = a+b+c;
      return d;
   }  
    
   static void main(String[] args) {
      PrintHello();
      println(sum(5, 50));
   } 
}