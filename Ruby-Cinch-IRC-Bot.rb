# Licencja - BSD:
# Tekst licencji:
# 	Copyright (C) 2014, Linux_Shines/Shiny
# 	Wszystkie prawa zastrzeżone.
# 	Redystrybucja i używanie, czy to w formie kodu źródłowego, czy w formie kodu wykonawczego, są dozwolone pod warunkiem spełnienia poniższych warunków:
# 		Redystrybucja kodu źródłowego musi zawierać powyższą notę dotyczącą praw autorskich, niniejszą listę warunków oraz poniższe oświadczenie o wyłączeniu odpowiedzialności.
# 		Redystrybucja kodu wykonawczego musi zawierać powyższą notę dotyczącą praw autorskich, niniejszą listę warunków oraz poniższe oświadczenie o wyłączeniu odpowiedzialności w dokumentacji i/lub w w innych materiałach dostarczanych wraz z kopią oprogramowania.
# 		Ani nazwa 'Ruby-Cinch-IRC-Bot', ani nazwa 'Ruby Cinch IRC Bot' nie mogą być użyte celem sygnowania lub promowania produktów pochodzących od tego oprogramowania, bez szczególnego, wyrażonego na piśmie ich zezwolenia.
# 		To oprogramowanie jest dostarczone przez użytkownika Linux_Shines/Shiny “tak, jak jest”. Każda, dorozumiana lub bezpośrednio wyrażona gwarancja, nie wyłączając dorozumianej gwarancji przydatności handlowej i przydatności do określonego zastosowania, jest wyłączona.
# 		W żadnym wypadku posiadacze praw autorskich nie mogą być odpowiedzialni za jakiekolwiek bezpośrednie, pośrednie, incydentalne, specjalne, uboczne i wtórne szkody (nie wyłączając obowiązku dostarczenia produktu zastępczego lub serwisu, odpowiedzialności z tytułu utraty walorów użytkowych, utraty danych lub korzyści a także przerw w pracy przedsiębiorstwa)
# 		spowodowane w jakikolwiek sposób i na podstawie istniejącej w torii odpowiedzialności kontraktowej, całkowitej lub deliktowej (wynikłej zarówno z niedbalstwa jak innych postaci winy), powstałe w jakikolwiek sposób w wyniku używania lub mające związek z używaniem oprogramowania, nawet jeśli o możliwości powstania takich szkód ostrzeżono.
				
require "cgi"								# Moduł cgi wymagany przez bota
require "cinch"								# Moduł cinch wymagany przez bota
require "json"								# Moduł json wymagany przez bota
require "nokogiri"							# Moduł nokogiri wymagany przez bota
require "open-uri"							# Moduł open-uri wymagany przez bota
require "rubygems"							# Moudł rubygems wymagany przez bota
require "wolfram"							# Moduł wolfram wymagany przez bota

BOT_FILE	 = open("bot.json")			# Plik .json, z którego będą odczytywane wszystkie opcje
BOT_PARSED	 = JSON.parse(BOT_FILE.read)

# Wymagana rejestracja http://products.wolframalpha.com/api/ aby je uzyskać:
Wolfram.appid    = BOT_PARSED["Wolfram"]["ID"]

# Podaj swój pseudonim, aby móc administrować botem:
ADMIN_OF_BOT	 = BOT_PARSED["Bot"]["Admin"]
# Pseudonim bota:
BOT_NAME         = BOT_PARSED["Bot"]["Name"]
# Hasło bota:
PASSWORD         = BOT_PARSED["Bot"]["Password"]
# Definiuje BOT_NICK jako "Pseudonim bota":
BOT_NICK         = BOT_NAME
# Definiuje BOT_REALNAME jako "Pseudonim bota":
BOT_REALNAME     = BOT_NAME
# Definiuje BOT_USER jako "Pseudonim bota":
BOT_USER         = BOT_REALNAME

# Port serwera IRC:
PORT             = BOT_PARSED["Config"]["Port"]
# Testing - "true" oznacza wejście bota na testowy kanał, false - wejście bota na prawdziwy kanał:
TESTING          = BOT_PARSED["Config"]["Testing"]
# Autorejoin - "true" oznacza, że po wyrzuceniu bota, będzie on po krótkiej chwili ponownie dołączać do czatu:
AUTOREJOIN	 = BOT_PARSED["Config"]["Autorejoin"]
# Definiuje host serwera. Wpisujesz go w formacie irc.tld lub irc.irc.tld:
SERVER_NAME      = BOT_PARSED["Config"]["Host"]

REGEX__GOOGLE    = /^!g (.+)/i			# Za pomocą wpisania !g tekst sprawdza i wyświetla pierwszy wynik z wyszukiwarki Google
REGEX__LENNY     = /\blenny(face)?\b/i		# Zwykłe wyrażenie regularne, sprawdzające, czy zostało wpisane lenny bądź lennyface na IRC
REGEX__SAY       = /\Asay (?<msg>.*)\z/i 	# Pisze jako bot po wpisaniu /msg nick_bota say wiadomość
REGEX__WOLFRAM   = /\A% (?<query>.*)\z/i 	# Sprawdza za pomocą wolframa różne wyniki/wiadomości

# Sprawdza, czy zdefiniowane wcześniej TESTING jest prawdziwe:
if TESTING == true					
	# Jeśli tak, wchodzi na kanał testowy:
	CHANNEL_NAME  = BOT_PARSED["Config"]["TestChanName"]
# Jeśli zdefiniowane wcześniej TESTING jest nieprawdziwe:
elsif TESTING == false
	# Wchodzi na zwykły kanał:
	CHANNEL_NAME  = BOT_PARSED["Config"]["RealChanName"]
# Koniec sprawdzenia:
end							

# Definiuje zmienną "bot" jako nowego bota frameworka Cinch
bot = Cinch::Bot.new do

	# Moduł "helpers" zawiera metody, które pozwalają na uproszczenie pisania pluginów bota, przez ukrywanie części API
	helpers do
	
		# Definiuje nową funkcję o nazwie Google, która ma za zadanie sprawdzać wyniki z wyszukiwarki Google
		def google(query)
		
			# Tworzy nową zmienną o nazwie "url" i przypisuje jej adres URL
			url = "http://www.google.pl/search?q=#{CGI.escape(query)}"
			
			# Tworzy nową zmienną o nazwie "res", przypisując jej możliwość otwarcia wcześniej zdefiniowanej zmiennej "url" za pomocą modułu Nokogiri, która wyszuka w kodzie przeglądarki nagłówek 3 poziomu z klasą o nazwie r (czyli <h3 class = "r">)
			res = Nokogiri::HTML(open(url)).at("h3.r")
			
			# Tworzy nową zmienną o nazwie "title", przypisując do poprzednio stworzonej zmiennej "res" możliwość pobrania tekstu za pomocą ".text"
			title = res.text
			
			# Tworzy nową zmienną o nazwie "link", przypisując do niej zmienną "res", która wyszuka w kodzie HTML wszystkie linki spod tagu <a href>
			link = res.at('a')[:href]
			
			# Tworzy nową zmienną o nazwie "desc", przypisując ją do zmiennej "res" i umożliwiając "podążanie" za tagiem <div> oraz jego dziećmi, które w pierwszej kolejności (.first) muszą być typem tekstowym (.text)
			desc = res.at("./following::div").children.first.text

			# W przypadku nieznalezienia żadnych wyników, pokazuje stosowny komunikat
			rescue "Nie znaleziono żadnych wyników."
			
			# W przypadku znalezienia wyników musi, za pomocą modułu cgi, odpowiednio spreparować treści HTML i usunąć wszelkie tagi (unescape_html), następnie pogrupować je według tytułu (title), opisu (desc) oraz podania linku (link) oraz przymusowo dekodować całą treść z ISO-8859-2 do UTF-8
			else
				# W przypadku znalezienia "krzaczków", każdy z nich jest zamieniany na polski odpowiednik za pomocą funkcji "gsub"
				CGI.unescape_html(CGI.unescape("#{title} - #{desc} (#{link})")).force_encoding("ISO-8859-2").encode("UTF-8") 
				.gsub("Âą", "ą")
				.gsub("ĂŚ", "ć")
				.gsub("ĂŞ", "ę")
				.gsub("Âł", "ł")
				.gsub("Ăą", "ń")
				.gsub("Ăł", "ó")
				.gsub("Âś", "ś")
				.gsub("Âź", "ź")
				.gsub("Âż", "ż")
				.gsub("â", "-")
				.gsub(/\Podobne+/, "")
				.gsub("âKopia", "")
				.gsub("âKopiaPodobne ", "")
				.gsub("âş", "")
				.gsub(/\(\/url\?q=/, "Link: ")
				.gsub(/\(\/images\?q=/, "Obrazek: ")
				.gsub(/\/&sa=.+/, "")
		# Kończy definicję funkcji google
		end
	# Zakończenie dla modułu "helpers"
	end
	
	# Podstawowa konfiguracja bota IRC, tworząca nową zmienną "c"
	configure do |c|
		c.server            = SERVER_NAME		# Konfiguruje zmienną c.server i przypisuje ją do zmiennej SERVER_NAME, zawierającej nazwę hosta serwera IRC
		c.port              = PORT				# Konfiguruje zmienną c.port i przypisuje ją do zmiennej PORT, zawierającej port serwera IRC
		c.channels          = [CHANNEL_NAME]	# Konfiguruje zmienną c.channels i przypisuje ją do zmiennej CHANNEL_NAME, zawierającej nazwę kanału IRC, na który ma wejść bot
		c.nick              = BOT_NICK			# Konfiguruje zmienną c.nick i przypisuje ją do zmiennej BOT_NICK, zawierającej nazwę bota
		c.user              = BOT_USER			# Konfiguruje zmienną c.user i przypisuje ją do zmiennej BOT_USER, zawierającej nazwę bota
		c.realname          = BOT_REALNAME		# Konfiguruje zmienną c.realname i przypisuje ją do zmiennej BOT_REALNAME, zawierającej prawdziwą nazwę bota
		c.password          = PASSWORD			# Konfiguruje zmienną c.password i przypisuje ją do zmiennej PASSWORD, zawierającej hasło dla bota
	# Kończy konfigurację bota
	end

	# Określa to co się dzieje, gdy bot wejdzie na kanał
	on :join do
		# Wysyła do serwera IRC informację "MODE BOT_NICK +B", która zawiera wiadomość o tym, że dany użytkownik jest botem
		bot.irc.send "MODE " + BOT_NICK + " +B"
	# Zakańcza daną funkcję
	end
	
# Jeżeli definicja AUTOREJOIN jest ustawiona na "true", funkcja poniżej wywoła się pomyślnie:
if AUTOREJOIN == true
	# Określa to co ma się dziać, gdy bot zostanie wyrzucony
	on :kick do
		# Wysyła - za pomocą zmiennej globalnej bot - do kanału o zdefiniowanej wcześniej nazwie "CHANNEL_NAME" informację, że bot ma wejść
		bot.Channel(CHANNEL_NAME).join
	# Zakańcza daną funkcję
	end
# Kończy sprawdzanie, czy definicja AUTOREJOIN jest ustawiona na "true":
end

	# Określa to co ma się dziać po wysłaniu określonej wiadomości (:message) (w tym wypadku tą wiadomością jest wyrażenie regularne, zdefiniowane jako REGEX__GOOGLE) i tworzy nowe zmienne, "m" oraz "params". Zmienna "params" pozwala na przechwycenie zawartości tego, co zostało wpisane
	on :message, REGEX__GOOGLE do |m, params|
		# Wysyła wiadomość do wszystkich użytkowników na czacie (m.reply), sprawdzając wcześniej za pomocą funkcji "google(query)" zapytanie do wyszukiwarki Google
		m.reply google(params)
	# Zakańcza funkcję wysyłającą wiadomość
	end
	
	# Określa to co ma się dziać po wysłaniu określonej wiadomości (:message) (w tym wypadku tą wiadomością jest wyrażenie regularne, zdefiniowane jako REGEX__SAY) i tworzy nową zmienną |m|
	on :message, REGEX__SAY do |m|
		# Gdy użytkownik (m.user.to_s.downcase)
			# gdzie:
				# m to zmienna
				# user to użytkownik IRC, w tym wypadku bot
				# to_s to konwersja do ciągu znaków
				# downcase to konwersja całej zawartości na małe litery
		# jest administratorem (do sprawdzenia służy definicja BOT_NAME)		
		if m.user.to_s.downcase == ADMIN_OF_BOT.downcase
			# Tworzy nową zmienną zawierającą w sobie wyrażenie regularne REGEX__SAY, sprawdzające w zmiennej m (m.message) całą wiadomość [:msg]
			msg = REGEX__SAY.match(m.message)[:msg]
			# Wysyła - za pomocą zmiennej globalnej bot - do kanału o zdefiniowanej wcześniej nazwie (Channel(CHANNEL_NAME)) wiadomość ze zmiennej "msg" do wszystkich osób na kanale
			bot.Channel(CHANNEL_NAME).msg msg
		# Kończy sprawdzanie, czy użytkownik jest administratorem
		end
	# Zakańcza funkcję wysyłającą wiadomość
	end

	# Określa to co ma się dziać po wysłaniu określonej wiadomości (:message) (w tym wypadku tą wiadomością jest wyrażenie regularne, zdefiniowane jako REGEX__WOLFRAM) i tworzy nową zmienną |m|
	on :message, REGEX__WOLFRAM do |m|
		# Tworzy nową zmienną o nazwie "query", która sprawdza wiadomość za pomocą wyrażenia regularnego, umieszczoną w zmiennej "m", przypisanej do wysyłanej wiadomości (REGEX__WOLFRAM.match(m.message)) i przechwytuje zapytanie [:query]
		query = REGEX__WOLFRAM.match(m.message)[:query]
		# Tworzy nową zmienną o nazwie "result", pobierającą zapytanie ze zmiennej "query"
		result = Wolfram.fetch(query)
		# Wysyła wiadomość do wszystkich użytkowników na czacie (m.reply) zawartość zmiennej "result", przekształcając ją tak do ciągu znaków (inspect)
		m.reply result.inspect
	# Zakańcza funkcję wysyłającą wiadomość
	end
# Kończy definiować funkcję "bot" jako nowego bota frameworka Cinch
end

# Uruchamia bota
bot.start
