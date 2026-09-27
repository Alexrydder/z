<template>
  <header class="gablvm-header" role="banner">
    <div class="gablvm-header__inner">
      <a class="gablvm-header__brand" href="/">GABLVM short links</a>
      <nav aria-label="Site">
        <ul class="gablvm-nav">
          <template v-if="isLoggedIn">
            <li><a href="/shortener/urls">My links</a></li>
            <li><a href="/shortener/groups">My collections</a></li>
            <li><a href="/shortener/api_keys">API</a></li>
            <template v-if="isAdmin">
              <li><a href="/shortener/admin/urls">All links</a></li>
              <li><a href="/shortener/admin/groups">All collections</a></li>
              <li><a href="/shortener/admin/members">Admins</a></li>
              <li><a href="/shortener/admin/audits">Audit log</a></li>
              <li><a href="/shortener/admin/announcements">Announcements</a></li>
            </template>
          </template>
          <li><a href="/shortener/faq">FAQ</a></li>
          <li><a href="mailto:help@gablvm.org">Contact</a></li>
          <li v-if="!isLoggedIn"><a href="/shortener/signin">Sign in</a></li>
          <li v-if="isLoggedIn"><a href="/shortener/signout">Sign out</a></li>
        </ul>
      </nav>
    </div>
  </header>
</template>
<script setup lang="ts">
import { computed } from "vue";
import type { User } from "@/types";

const props = withDefaults(
  defineProps<{
    currentUser: User | null;
  }>(),
  {
    currentUser: null,
  }
);

const isLoggedIn = computed(() => props.currentUser !== null);
const isAdmin = computed(() => props.currentUser?.admin ?? false);
</script>
<style>
.gablvm-header {
  background: #0f3d1a;
  color: #faf7f0;
  border-bottom: 3px solid #a67c2b;
}
.gablvm-header__inner {
  max-width: 72rem;
  margin: 0 auto;
  padding: 1rem;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem 1.5rem;
}
.gablvm-header__brand {
  font-family: Fraunces, Georgia, serif;
  font-size: 1.5rem;
  font-weight: 600;
  color: #faf7f0;
  text-decoration: none;
}
.gablvm-header__brand:hover,
.gablvm-header__brand:focus {
  color: #e5c178;
  text-decoration: underline;
}
.gablvm-nav {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-wrap: wrap;
  gap: 0.25rem 1.25rem;
}
.gablvm-nav a {
  color: #faf7f0;
  text-decoration: none;
  padding: 0.25rem 0;
  display: inline-block;
}
.gablvm-nav a:hover,
.gablvm-nav a:focus {
  color: #e5c178;
  text-decoration: underline;
}
.gablvm-header a:focus-visible,
.gablvm-footer a:focus-visible {
  outline: 3px solid #c69a3e;
  outline-offset: 2px;
}
</style>
