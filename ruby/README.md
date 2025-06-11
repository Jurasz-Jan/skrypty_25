Allegro w tej chwili praktycznie na samym wejściu na stronę główną (https://allegro.pl/) sprawdza:

- fingerprint TLS

- JA3 hash po handshake

- IP reputację

- brak sesji JS


Z kolei Ceneo zidentyfikowało open-uri.

Obie te opcje sprawiają, że realne efekty, bez użycia Selenium itd. są nieosiągalne.

1️⃣ Ceneo zmieniło sposób renderowania strony
2️⃣ Nokogiri przetwarza wyłącznie "surowy HTML"
3️⃣ Ceneo wdrożyło dodatkowo mechanizmy anti-bot / bot-detection
4️⃣ Allegro wdrożyło niezwykle rygorystyczne mechanizmy anti-bot / bot-detection, nie jestem w stanie nawet parseować html(403)