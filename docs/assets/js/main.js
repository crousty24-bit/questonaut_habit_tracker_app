const headTemplatePath = "partials/head.html";

async function injectSharedHead() {
  const body = document.body;
  if (!body) return;

  try {
    const response = await fetch(headTemplatePath);
    if (!response.ok) return;

    const template = await response.text();
    const title = body.dataset.title || "Questonaut";
    const description = body.dataset.description || "Questonaut static showcase";
    const ogImage = new URL(body.dataset.ogImage || "assets/img/og/questonaut-og.png", window.location.href).href;
    const canonical = window.location.href;

    const headMarkup = template
      .replaceAll("__TITLE__", title)
      .replaceAll("__DESCRIPTION__", description)
      .replaceAll("__OG_IMAGE__", ogImage)
      .replaceAll("__CANONICAL__", canonical);

    document.title = title;
    document.head.querySelectorAll("[data-managed-head]").forEach((node) => node.remove());

    const wrapper = document.createElement("template");
    wrapper.innerHTML = headMarkup;

    [...wrapper.content.children].forEach((node) => {
      node.setAttribute("data-managed-head", "true");
      document.head.appendChild(node);
    });
  } catch (_error) {
    // The page remains usable even if shared metadata cannot be loaded.
  }
}

async function loadIncludes() {
  const targets = [...document.querySelectorAll("[data-include]")];

  await Promise.all(targets.map(async (target) => {
    const file = target.dataset.include;
    if (!file) return;

    try {
      const response = await fetch(file);
      if (!response.ok) return;
      target.innerHTML = await response.text();
    } catch (_error) {
      // The page content stays accessible if a fragment cannot be loaded.
    }
  }));
}

function markActiveNav() {
  const current = document.body.dataset.page;
  document.querySelectorAll("[data-nav]").forEach((link) => {
    if (link.dataset.nav === current) {
      link.classList.add("is-active");
      link.setAttribute("aria-current", "page");
    }
  });
}

function setCurrentYear() {
  document.querySelectorAll("[data-current-year]").forEach((node) => {
    node.textContent = String(new Date().getFullYear());
  });
}

function initMenu() {
  const button = document.querySelector(".menu-toggle");
  const nav = document.querySelector(".site-nav");
  if (!button || !nav) return;

  button.addEventListener("click", () => {
    const isOpen = nav.classList.toggle("is-open");
    button.setAttribute("aria-expanded", String(isOpen));
  });

  nav.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      nav.classList.remove("is-open");
      button.setAttribute("aria-expanded", "false");
    });
  });
}

function initReveal() {
  const nodes = document.querySelectorAll(".reveal");
  if (!nodes.length) return;

  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-visible");
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  nodes.forEach((node) => observer.observe(node));
}

async function bootstrap() {
  await injectSharedHead();
  await loadIncludes();
  markActiveNav();
  setCurrentYear();
  initMenu();
  initReveal();
}

document.addEventListener("DOMContentLoaded", bootstrap);
