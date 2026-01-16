import { test, expect } from "@playwright/test";

test("homepage has title and links to intro page", async ({ page }) => {
  await page.goto("http://localhost:3000/");

  await expect(page).toHaveTitle("Welcome to Leptos");

  await expect(page.locator("h1")).toHaveText("Welcome to Leptos!");
});

test("button increments count when clicked", async ({ page }) => {
  await page.goto("http://localhost:3000/");

  const button = page.locator("button");
  await expect(button).toHaveText(/Click Me: \s*0/);

  await button.click();
  await expect(button).toHaveText(/Click Me: \s*1/);

  await button.click();
  await expect(button).toHaveText(/Click Me: \s*2/);
});
