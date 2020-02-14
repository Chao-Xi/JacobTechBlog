import pika
username    = "admin"
passwd      = "admin"
auth    = pika.PlainCredentials(username, passwd)
s_conn  = pika.BlockingConnection(pika.ConnectionParameters('192.168.33.10', credentials=auth))
channel = s_conn.channel()
channel.queue_declare(queue='hello')
for i in range(1,100000):
    channel.basic_publish(exchange='', routing_key='hello', body='message '+ str(i))
    print("[Sender] send 'hello" + 'message '+ str(i))

s_conn.close()