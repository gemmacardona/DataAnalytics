import asyncio
from playwright.async_api import async_playwright
import os
import aiohttp
import aiofiles
import pandas as pd
from datetime import datetime

# Lista de nombres de usuario de TikTok
usernames = ["martstips"]

def convert_views(views_str):
    if 'K' in views_str:
        return int(float(views_str.replace('K', '')) * 1000)
    elif 'M' in views_str:
        return int(float(views_str.replace('M', '')) * 1000000)
    else:
        return int(views_str)


async def run(playwright, username):
    browser = await playwright.chromium.launch(headless=False)
    page = await browser.new_page()
    await page.goto(f'https://www.tiktok.com/@{username}')

    print(f"Página de {username} cargada correctamente. Obteniendo contenido...")

    for _ in range(48):
        await page.mouse.wheel(0, 2000)
        await page.wait_for_timeout(3000)

    await page.wait_for_selector('a[href*="/video/"]', timeout=60000)

    all_links_elements = await page.query_selector_all('a[href*="/video/"]')

    today = datetime.today().strftime('%Y-%m-%d')
    folder_name = "D:\\DDAA\\Sprint10\\ObtenirDades"
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)

    video_data = []
    
    for link in all_links_elements:
        href = await link.get_attribute('href')
        if href and href.startswith('https://www.tiktok.com/'):
            parent = await link.query_selector('xpath=ancestor::div[contains(@class, "DivContainer")]')
            if parent:
                views_element = await parent.query_selector('strong[data-e2e="video-views"]')
                picture_element = await parent.query_selector('picture img')
                if views_element and picture_element:
                    views_text = await views_element.inner_text()
                    views_number = convert_views(views_text)
                    video_data.append((href, views_number))
                    
    video_data = list(set(video_data))

    print(f"Se encontraron {len(video_data)} videos únicos para {username}:")
    for link, views in video_data:
        print(f"{link} - {views}")

    video_filename = os.path.join(folder_name, f'urls_martstips.xlsx')
    df_videos = pd.DataFrame(video_data, columns=['Video Links', 'Views'])
    df_videos['id_perfil'] = username
    df_videos.to_excel(video_filename, index=False)
    print(f'Los enlaces de video, sus vistas y los nombres de las imágenes se han guardado en el archivo {video_filename}.')

    
async def main():
    async with async_playwright() as playwright:
        tasks = [run(playwright, username) for username in usernames]
        await asyncio.gather(*tasks)

asyncio.run(main())

