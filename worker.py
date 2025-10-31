from bot import bot
import asyncio

async def main():
    await bot.polling(none_stop=True)

if __name__ == '__main__':
    asyncio.run(main())
