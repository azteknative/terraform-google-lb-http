/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "tls_private_key" "example" {
  count     = 3
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "example" {
  count           = 3
  key_algorithm   = "${element(tls_private_key.example.*.algorithm, count.index)}"
  private_key_pem = "${element(tls_private_key.example.*.private_key_pem, count.index)}"

  # Certificate expires after 12 hours.
  validity_period_hours = 12

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["example-${count.index + 1}.com"]

  subject {
    common_name  = "example-${count.index + 1}.com"
    organization = "ACME Examples, Inc"
  }
}

resource "google_compute_ssl_certificate" "example" {
  count       = 3
  name        = "${var.network_name}-cert-${count.index + 1}"
  private_key = "${element(tls_private_key.example.*.private_key_pem, count.index)}"
  certificate = "${element(tls_self_signed_cert.example.*.cert_pem, count.index)}"
}
