<template>
  <footer class="gablvm-footer" role="contentinfo">
    <div class="gablvm-footer__inner">
      <p>
        Short links for the Global Advocacy of Blind and Low Vision Muslims.
        Questions or a broken link: <a href="mailto:help@gablvm.org">help@gablvm.org</a>.
      </p>
      <ul class="gablvm-footer__links">
        <li><a href="https://gablvm.org/">gablvm.org</a></li>
        <li><a href="https://github.com/Alexrydder/z/tree/gablvm">Source code, the GABLVM branch of Z, open source under the AGPL</a></li>
        <li><a href="https://gablvm.org/privacy-policy">Privacy</a></li>
      </ul>
    </div>
  </footer>
</template>
<script setup lang="ts"></script>
<style>
.gablvm-footer {
  background: #0f3d1a;
  color: #faf7f0;
  border-top: 3px solid #a67c2b;
  margin-top: 2rem;
}
.gablvm-footer__inner {
  max-width: 72rem;
  margin: 0 auto;
  padding: 1.5rem 1rem;
  font-size: 0.95rem;
}
.gablvm-footer a {
  color: #e5c178;
}
.gablvm-footer__links {
  list-style: none;
  margin: 0.75rem 0 0;
  padding: 0;
}
.gablvm-footer__links li {
  display: block;
  margin: 0.25rem 0;
}
</style>
