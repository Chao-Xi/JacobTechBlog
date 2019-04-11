using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace HelloWorld
{
    class Program
    {

        public static int count = -1;
        static void Main(string[] args)
        {
            Stopwatch s = new Stopwatch();
            s.Start();
            List<string> records = new List<string>();
            CreateRecords(records);
            ProcessRecords(records);
            s.Stop();
            Console.WriteLine("Process elapsed : {0}", s.ElapsedMilliseconds);
            Console.ReadKey();
        }


        public static string MD5Hash(string input)
        {
            StringBuilder hash = new StringBuilder();
            MD5CryptoServiceProvider md5provider = new MD5CryptoServiceProvider();
            byte[] bytes = md5provider.ComputeHash(new UTF8Encoding().GetBytes(input));

            for (int i = 0; i < bytes.Length; i++)
            {
                hash.Append(bytes[i].ToString("x2"));
            }
            return hash.ToString();
        }

        public static void ProcessRecords(List<string> records)
        {
            Parallel.ForEach(records, new ParallelOptions() { MaxDegreeOfParallelism = 20 }, a =>
            {
                var data = MD5Hash(a);
                Interlocked.Increment(ref count);
                Console.WriteLine("Proccessed : {0} - {1}", a, count);
                Thread.Sleep(1);

            });

        }
        public static void CreateRecords(List<string> records)
        {
            var chars = new[] { "A", "B", "C", "D", "E", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" };

            var stringLength = 32;
            Random r = new Random();
            var maxLength = chars.Length;

            for (int j = 0; j < 100000; j++)
            {
                var baseString = "";
                for (int i = 0; i < stringLength; i++)
                {

                    baseString += chars[r.Next(0, maxLength)].ToString();
                }
                records.Add(baseString);
                Console.WriteLine("String produced {0} - {1}", baseString, j);
                Thread.Sleep(2);
            }

        }
    }
}