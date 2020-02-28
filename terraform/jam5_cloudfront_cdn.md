# Jam AWS Cloud Distribution 

### Resource: `aws_cloudfront_distribution`

Creates an Amazon CloudFront web distribution.


## `var.tf`

```
variable "certificate_arn" {}
variable "DNS_ZONE" {}
variable "JAM_INSTANCE" {}
```


## `main.tf`

```
resource "aws_cloudfront_distribution" "cdn" {
  aliases = [
    "cdn-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets0-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets2-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets1-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets3-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
  ]
  default_root_object = ""

  origin {
    origin_id   = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    domain_name = "${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1.1",
        "TLSv1.2"
      ]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
  }
  default_cache_behavior {
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = true
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    allowed_methods = [
      "HEAD",
      "GET"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 86400
    max_ttl          = 31536000
    compress         = true
  }

  ordered_cache_behavior {
    path_pattern     = "cdn/videos/*"
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward           = "whitelist"
        whitelisted_names = ["cdn_auth*"]
      }
      query_string            = true
      query_string_cache_keys = ["cachevar"]
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 1
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 1
    max_ttl          = 604800
    compress         = true
  }

  ordered_cache_behavior {
    path_pattern     = "cdn/*"
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string            = true
      query_string_cache_keys = ["cachevar"]
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 1
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 1
    max_ttl          = 31536000
    compress         = true
  }

  ordered_cache_behavior {
    path_pattern     = "api/*"
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward = "all"
      }
      query_string = true
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 86400
    max_ttl          = 31536000
    compress         = true
  }
  custom_error_response {
    error_code            = 404
    response_page_path    = ""
    error_caching_min_ttl = 5
  }
  comment     = ""
  price_class = "PriceClass_All"
  enabled     = true
  viewer_certificate {
    acm_certificate_arn      = "${var.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  web_acl_id      = ""
  http_version    = "http2"
  is_ipv6_enabled = false
}
```

* `aliases` (Optional) - Extra `CNAMEs` (alternate domain names), if any, for this distribution.

```
aliases = [
    "cdn-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets0-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets2-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets1-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com",
    "assets3-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
  ]
```

* `default_root_object` (Optional) - **The object that you want CloudFront to return** (for example, index.html) when an end user requests the root URL.


## Origin Arguments:

* **`origin` (Required) - One or more origins for this distribution**

```
origin {
    origin_id   = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    domain_name = "${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [
        "TLSv1.1",
        "TLSv1.2"
      ]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
  }
```

* `origin_id` (Required) - A unique identifier for the origin.
* `domain_name` (Required) - The DNS domain name of either the **S3 bucket, or web site of your custom origin**.
* `custom_origin_config` - The CloudFront custom origin configuration information. If an `S3` origin is required, use `s3_origin_config` instead.
  * **Custom Origin Config Arguments**
  * `http_port` (Required) - The HTTP port the custom origin listens on.
  * `https_port` (Required) - The HTTPS port the custom origin listens on.
  * `origin_protocol_policy` (Required) - The origin protocol policy to apply to your origin. One of `http-only`, `https-only`, or `match-viewer`.
  * `origin_ssl_protocols` (Required) - The `SSL/TLS` protocols that you want CloudFront to use when communicating with your origin over HTTPS. A list of one or more of `SSLv3`, `TLSv1`, `TLSv1.1`, and `TLSv1.2`.
  * `origin_keepalive_timeout` - (Optional) The Custom KeepAlive timeout, in seconds. By default, AWS enforces a limit of `60`.
  * `origin_read_timeout` - (Optional) The Custom Read timeout, in seconds. By default, AWS enforces a limit of `60`.



### Cache Behavior Arguments

* **`default_cache_behavior` (Required) - The default cache behavior for this distribution (maximum one)**.

```
default_cache_behavior {
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = true
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    allowed_methods = [
      "HEAD",
      "GET"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 86400
    max_ttl          = 31536000
    compress         = true
  }
```

* `target_origin_id` (Required) - The value of ID for the origin that you want CloudFront to route requests to when a request matches the path pattern either for a cache behavior or for the default cache behavior.
* `forwarded_values` (Required) - **The forwarded values configuration that specifies how CloudFront handles query strings, cookies and headers (maximum one)**.
 * **Forwarded Values Arguments**
 * `cookies` (Required) - **The forwarded values cookies that specifies how CloudFront handles cookies** (maximum one).
     * **Cookies Arguments**
     * `forward (Required)` - **Specifies whether you want CloudFront to forward cookies to the origin that is associated with this cache behavior**. You can specify `all`, `none` or `whitelist`. If `whitelist`, you must include the subsequent `whitelisted_names`
 * `query_string` (Required) - **Indicates whether you want CloudFront to forward query strings to the origin that is associated with this cache behavior.**

* `viewer_protocol_policy` (Required) - **Use this element to specify the protocol that users can use to access the files in the origin specified by TargetOriginId** when a request matches the path pattern in PathPattern. One of `allow-all`, `https-only`, or `redirect-to-https`.
* `min_ttl (Optional)` - **The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated**. Defaults to `0` seconds.
* `allowed_methods` (Required) - Controls which HTTP methods CloudFront processes and forwards to your **Amazon S3 bucket or your custom origin**.
* `cached_methods` (Required) - Controls whether CloudFront caches the response to requests using the specified HTTP methods.
* `smooth_streaming` (Optional) - Indicates whether you want to distribute media files in Microsoft Smooth Streaming format using the origin that is associated with this cache behavior.
* `default_ttl` (Optional) - The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an `Cache-Control max-age` or `Expires` header. Defaults to `1` day.
* `max_ttl` (Optional) - The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Only effective in the presence of `Cache-Control max-age`, `Cache-Control s-maxage`, and `Expires headers`. Defaults to `365` days.
* `compress` (Optional) - Whether you want CloudFront to automatically compress content for web requests that include Accept-Encoding: `gzip` in the request header (`default: false`).


### `ordered_cache_behavior(cdn/videos/*)`

```
ordered_cache_behavior {
    path_pattern     = "cdn/videos/*"
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward           = "whitelist"
        whitelisted_names = ["cdn_auth*"]
      }
      query_string            = true
      query_string_cache_keys = ["cachevar"]
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 1
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 1
    max_ttl          = 604800
    compress         = true
  }
```

`ordered_cache_behavior` (Optional) - **An ordered list of cache behaviors resource for this distribution.** 

List from top to bottom in order of precedence. The topmost cache behavior will have precedence `0`.

* `path_pattern` (Required) - The pattern (for example, `images/*.jpg`) that specifies which requests you want this cache behavior to apply to.
* `forwarded_values cookies` 
  * `whitelisted_names` (Optional) - If you have specified `whitelist` to `forward`, the whitelisted cookies that you want CloudFront to forward to your origin.
  * `query_string_cache_keys` (Optional) - When specified, along with a value of `true` for `query_string`, all query strings are forwarded, however only the query string keys listed in this argument are cached. When omitted with a value of `true` for `query_string`, **all query string keys are cached**.

```
query_string            = true
query_string_cache_keys = ["cachevar"]
```


```
allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
```

### `ordered_cache_behavior(cdn/*)`

```
ordered_cache_behavior {
    path_pattern     = "cdn/*"
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string            = true
      query_string_cache_keys = ["cachevar"]
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 1
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 1
    max_ttl          = 31536000
    compress         = true
  }
```

### `ordered_cache_behavior(api/*)`

```
ordered_cache_behavior {
    path_pattern     = "api/*"
    target_origin_id = "Custom-${var.JAM_INSTANCE}.${var.DNS_ZONE}.com"
    forwarded_values {
      cookies {
        forward = "all"
      }
      query_string = true
    }
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    allowed_methods = [
      "HEAD",
      "DELETE",
      "POST",
      "GET",
      "OPTIONS",
      "PUT",
      "PATCH"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    smooth_streaming = false
    default_ttl      = 86400
    max_ttl          = 31536000
    compress         = true
  }
  custom_error_response {
    error_code            = 404
    response_page_path    = ""
    error_caching_min_ttl = 5
  }
  comment     = ""
  price_class = "PriceClass_All"
  enabled     = true
  viewer_certificate {
    acm_certificate_arn      = "${var.certificate_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  web_acl_id      = ""
  http_version    = "http2"
  is_ipv6_enabled = false
}
```

* `custom_error_response `(Optional) - **One or more custom error response elements (multiples allowed).**
* **Custom Error Response Arguments**
 * `error_code` (Required) - The `4xx` or `5xx` HTTP status code that you want to customize.
 * `response_page_path` (Optional) - The path of the custom error page (for example, `/custom_404.html`).
 * `error_caching_min_ttl` (Optional) - **The minimum amount of time you want `HTTP` error codes to stay in CloudFront caches** before CloudFront queries your origin to see whether the object has been updated.

* `restrictions` (Required) - The restriction configuration for this distribution (maximum one).
 * **Restrictions Arguments**: The restrictions sub-resource takes another single sub-resource named `geo_restriction` 
 * The arguments of `geo_restriction` are:
 * `restriction_type` (Required) - The method that you want to use to restrict distribution of your content by country: `none`, `whitelist`, or `blacklist`.


* `web_acl_id` (Optional) - If you're using `AWS WAF(Web application Firewall) `to filter CloudFront requests, the Id of the AWS WAF web ACL that is associated with the distribution. The WAF Web ACL must exist in the `WAF Global (CloudFront)` region and the credentials configuring this argument must have `waf:GetWebACL `permissions assigned.
* `http_version` (Optional) - The maximum HTTP version to support on the distribution. Allowed values are `http1.1` and `http2`. The default is `http2`
* `is_ipv6_enabled` (Optional) - Whether the IPv6 is enabled for the distribution.


##  `output.tf`

```
output "cdn_domain_name" {
  value = "${aws_cloudfront_distribution.cdn.domain_name}"
}
```


```
$ terraform apply --target=module.cdn
var.route_table_ids
  Enter a value: []

module.cdn.aws_cloudfront_distribution.cdn: Refreshing state... [id=ET5L2EVX83JZG]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

aws_acm_certificate_arn = arn:aws:acm:eu-central-1:{}:certificate/01279bc2-b7
d8-4730-985a-551e85c468f4
cdn_domain_name = d1{}.cloudfront.net
docconversion_access_key_id = {}
mysql_hostname = integration702-db.{}.eu-central-1.rds.amazonaws.com
objectstore_access_key_id = {}
```
