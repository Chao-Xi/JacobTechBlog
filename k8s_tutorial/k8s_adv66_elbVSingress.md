# Ingress vs Load Balancer

## Load Balancer

A kubernetes LoadBalancer service is a service that points to external load balancers that **are NOT in your kubernetes cluster**, but exist elsewhere. 

They can work with your pods, assuming that your pods are externally routable. Google and AWS provide this capability natively. 

In terms of Amazon, this maps directly with ELB and kubernetes when running in **AWS can automatically provision and configure an ELB instance for each LoadBalancer service deployed**.

## Ingress

An ingress is really just a set of rules to pass to a controller that is listening for them. 

You can deploy a bunch of ingress rules, but nothing will happen unless you have a controller that can process them. 

**A LoadBalancer service could listen for ingress rules, if it is configured to do so.**

## NodePort

You can also create a **NodePort service**, which has an externally routable IP outside the cluster, but points to a pod that exists within your cluster. This could be an Ingress Controller.

## Application Load Balancer

An Ingress Controller is simply a pod that is configured to interpret ingress rules. One of the most popular ingress controllers supported by kubernetes is nginx. In terms of Amazon, ALB can be used as an [ingress controller](https://github.com/kubernetes/ingress-nginx/).

[How to install `nginx-ingress` inside cluster](k8s_adv51_Nginx_Ingress.md)

For an example, this nginx controller is able to ingest ingress rules you have defined and translate them to an nginx.conf file that it loads and starts in its pod.

Let's for instance say you defined an ingress as follows:

```
piVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
   ingress.kubernetes.io/rewrite-target: /
 name: web-ingress
spec:
  rules:
  - host: kubernetes.foo.bar
    http:
      paths:
      - backend:
          serviceName: appsvc
          servicePort: 80
        path: /app
```

If you then inspect your nginx controller pod you'll see the following rule defined in `/etc/nginx.conf`:

```
server {
    server_name kubernetes.foo.bar;
    listen 80;
    listen [::]:80;
    set $proxy_upstream_name "-";
    location ~* ^/web2\/?(?<baseuri>.*) {
        set $proxy_upstream_name "apps-web2svc-8080";
        port_in_redirect off;

        client_max_body_size                    "1m";

        proxy_set_header Host                   $best_http_host;

        # Pass the extracted client certificate to the backend

        # Allow websocket connections
        proxy_set_header                        Upgrade           $http_upgrade;
        proxy_set_header                        Connection        $connection_upgrade;

        proxy_set_header X-Real-IP              $the_real_ip;
        proxy_set_header X-Forwarded-For        $the_x_forwarded_for;
        proxy_set_header X-Forwarded-Host       $best_http_host;
        proxy_set_header X-Forwarded-Port       $pass_port;
        proxy_set_header X-Forwarded-Proto      $pass_access_scheme;
        proxy_set_header X-Original-URI         $request_uri;
        proxy_set_header X-Scheme               $pass_access_scheme;

        # mitigate HTTPoxy Vulnerability
        # https://www.nginx.com/blog/mitigating-the-httpoxy-vulnerability-with-nginx/
        proxy_set_header Proxy                  "";

        # Custom headers

        proxy_connect_timeout                   5s;
        proxy_send_timeout                      60s;
        proxy_read_timeout                      60s;

        proxy_redirect                          off;
        proxy_buffering                         off;
        proxy_buffer_size                       "4k";
        proxy_buffers                           4 "4k";

        proxy_http_version                      1.1;

        proxy_cookie_domain                     off;
        proxy_cookie_path                       off;

    rewrite /app/(.*) /$1 break;
    rewrite /app / break;
    proxy_pass http://apps-appsvc-8080;

    }
```

Nginx has just created a rule to route `http://kubernetes.foo.bar/app` to point to the service appsvc in your cluster.

