import pika
def callback(ch, method, properties, body):
    print(" [Consumer] Received %r" % body)
    #ch.basic_ack(delivery_tag = method.delivery_tag)
username    = "admin"
passwd      = "admin"
auth    = pika.PlainCredentials(username, passwd)
s_conn  = pika.BlockingConnection(pika.ConnectionParameters('192.168.33.10', credentials=auth))
channel = s_conn.channel()
channel.queue_declare(queue='hello')
channel.basic_qos(prefetch_count=1)

# channel.basic_consume(consumer_callback=callback,queue="hello",no_ack=True)
channel.basic_consume(on_message_callback=callback, queue="hello", auto_ack=True)

print(' [*] Waiting for messages. To exit press CTRL+C')
channel.start_consuming()