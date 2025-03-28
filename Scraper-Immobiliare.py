import time
import random
import requests
import pandas as pd
from bs4 import BeautifulSoup as bs
from fake_useragent import UserAgent

class Scraper(object):
    def __init__(self, page = 1, city = None):

        if not isinstance(page, int) or page <= 0:
            raise ValueError(f" {page} must be an integer number greater than 0")

        if city is None:
            raise ValueError("Parameter city missing, please select a city")

        if not isinstance(city, str):
            raise ValueError(f"{city} must be a string")

        self.pages = page
        self.cities = city.replace(" ","-")

    @staticmethod
    def get_soup(url):

        if not isinstance(url, str):
            raise ValueError(f"{url} deve essere una stringa.")

        if not url.startswith(("http://", "https://")):
            raise ValueError(f"{url} deve iniziare con 'http://' o 'https://'.")

        max_attempts = 10
        attempts = 0

        ua = UserAgent()

        while attempts < max_attempts:
            try:
                # Sosta casuale prima della richiesta
                time.sleep(random.uniform(1, 3))

                headers = {
                    "User-Agent": ua.random,
                    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
                    "Accept-Language": "en-US,en;q=0.9",
                    "Accept-Encoding": "gzip, deflate, br",
                    "Connection": "keep-alive",
                    "Upgrade-Insecure-Requests": "1",
                    "Cache-Control": "max-age=0",
                    "Referer": "https://www.google.com/"
                }

                response = requests.get(url, headers=headers, timeout=10)
                if response.status_code == 200:
                    # Leggero sleep dopo la risposta per dare l'idea di elaborazione
                    time.sleep(random.uniform(0.5, 1.5))
                    return bs(response.text, "html.parser")
                else:
                    attempts += 1
                    time.sleep(2)

            except requests.exceptions.RequestException:
                attempts += 1
                time.sleep(2)

        raise ConnectionError(f"Impossibile ottenere l'HTML da {url} dopo {max_attempts} tentativi.")

    def max_page(self):
        start_link = f"https://www.immobiliare.it/vendita-case/{self.cities}/"

        get_max_page = self.get_soup(start_link)

        pagination_list = get_max_page.find("div", {"data-cy": "pagination-list"})

        if pagination_list is None:
            return 1
        else:
            disabled_items = pagination_list.find_all("div",
                class_="nd-button nd-button--ghost is-disabled in-paginationItem is-mobileHidden")
            max_page = int(disabled_items[-1].get_text(strip=True))

        return max_page

    def get_links(self):
        lst_out = []

        max_page = self.max_page()

        if self.pages > max_page:
            raise ValueError(f"Total number of pages ({self.pages}) in Exide Maximum: {max_page}")


        lst_links = [f"https://www.immobiliare.it/vendita-case/{self.cities}/?pag={page}#geohash-srbj60jf"
                     for page in range(1, self.pages + 1)]

        for str_link in lst_links:
            # Ulteriore sleep (opzionale) prima di richiamare get_soup
            time.sleep(random.uniform(1, 3))

            soup_link = self.get_soup(str_link)
            lst_links_tmp = [
                a_tag["href"]
                for a_tag in soup_link.find_all("a", class_="in-listingCardTitle")
            ]
            lst_out.extend(lst_links_tmp)
        return lst_out


    @staticmethod
    def sec_feat(soup):
        dct_tmp = dict()

        tmp_lst = [
            "Tipologia", "Piano", "Ascensore", "Locali", "Cucina", "Arredato",
            "Terrazzo", "Contratto", "Piani edificio", "Superficie",
            "Camere da letto", "Bagni", "Balcone", "Box, posti auto", "Prezzo", "Prezzo al m²", "Spese condominio"
        ]

        for item in tmp_lst:
            dt = soup.find("dt", class_="re-featuresItem__title", string=item)
            if dt:
                dd = dt.find_next_sibling("dd", class_="re-featuresItem__description")
                value = dd.get_text(strip=True) if dd else None
            else:
                value = None
            dct_tmp[item] = value

        return dct_tmp

    def prc_feat(self, soup):
        # Se la funzione prc_feat non esisteva nel tuo snippet, puoi aggiungere la logica qui.
        # Come esempio, la lasciamo vuota. Se esiste, spostala su e inserisci la tua logica.
        return {}

    def scraping(self):
        lst_out = []

        link_list = self.get_links()

        for i, link in enumerate(link_list, 1):
            # Pausa random fra una pagina e l’altra
            time.sleep(random.uniform(1, 3))

            soup = self.get_soup(link)
            dct_tmp = dict()

            dct_tmp["url"] = link

            dct_prc = self.prc_feat(soup)
            dct_tmp.update(dct_prc)

            scrape_filter = soup.find("dt", class_="re-featuresItem__title", string="Unità")

            if scrape_filter is not None:
                print(f"Under-construction apartment, not valid {i} / {len(link_list)}")
                continue

            dct_sec = self.sec_feat(soup)
            dct_tmp.update(dct_sec)

            lst_out.append(dct_tmp)

            print(f"Scrap Scrap Scrap {i} / {len(link_list)}")

        df = pd.DataFrame(lst_out)
        return df


if __name__ == "__main__":
    scrap = Scraper(80, "bologna")
    df = scrap.scraping()
    print(df)
