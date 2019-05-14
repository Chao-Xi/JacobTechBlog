class Example {
    static void main(String[] args) {
        // 初始化两个变量
        int x = 5; 
        int X = 6; 
        
        // 打印变量值
        println("x = " + x + " and X = " + X);  
        println("x = ${x} and X = ${X}");
        println('x = ${x} and X = ${X}');


println """
x = ${x}
X = ${X}
"""

println '''
x = ${x}
X = ${X}
'''
    }
}