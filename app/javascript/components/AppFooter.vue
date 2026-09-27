<template>
  <footer class="gablvm-footer" role="contentinfo">
    <div class="gablvm-footer__inner">
      <h2 class="gablvm-visually-hidden" id="gablvm-footer-heading">Footer</h2>
      <nav aria-labelledby="gablvm-footer-heading">
        <ul class="gablvm-footer__links">
          <li><a href="https://gablvm.org/">gablvm.org</a></li>
          <li><a href="https://gablvm.org/accessibility-statement">Accessibility Statement</a></li>
          <li><a href="https://gablvm.org/code-conduct">Code of Conduct</a></li>
          <li><a href="https://gablvm.org/cookie-policy">Cookie Policy</a></li>
          <li><a href="https://gablvm.org/privacy-policy">Privacy Policy</a></li>
          <li><a href="https://gablvm.org/terms-and-conditions">Terms and Conditions</a></li>
          <li><a href="https://status.gablvm.org/status">System status</a></li>
          <li><a href="https://gablvm.org/form/site-feedback">Report an accessibility issue or send feedback</a></li>
          <li><a href="/faq">Short links FAQ</a></li>
        </ul>
      </nav>
      <p class="gablvm-footer__note">
        This short link service is developed and maintained by the Global Advocacy of Blind and Low Vision Muslims (GABLVM).
        A short link only forwards you to another address. GABLVM is not responsible for the content of destinations it does not operate.
        Questions or a broken link: <a href="mailto:help@gablvm.org">help@gablvm.org</a>.
      </p>
      <p class="gablvm-footer__note">
        Runs on <a href="https://github.com/UMN-LATIS/z">Z</a>, open source software from the University of Minnesota, under the GNU Affero General Public License.
        <a href="https://github.com/Alexrydder/z/tree/gablvm">Source code of this copy</a>.
      </p>
      <p class="gablvm-footer__copyright">&copy; {{ year }} Global Advocacy of Blind and Low Vision Muslims (GABLVM). All rights reserved.</p>
    </div>
  </footer>
</template>
<script setup lang="ts">
const year = new Date().getFullYear();
</script>
<style>
.gablvm-visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
.gablvm-footer {
  background: #0f3d1a;
  color: #faf7f0;
  border-top: 3px solid #a67c2b;
  margin-top: 3rem;
}
.gablvm-footer__inner {
  max-width: 72rem;
  margin: 0 auto;
  padding: 2rem 1rem;
  font-size: 0.95rem;
  line-height: 1.6;
}
.gablvm-footer a {
  color: #e5c178;
}
.gablvm-footer__links {
  list-style: none;
  margin: 0 0 1.5rem;
  padding: 0;
}
.gablvm-footer__links li {
  display: block;
  margin: 0.35rem 0;
}
.gablvm-footer__note {
  max-width: 68ch;
  margin: 0 0 1rem;
  color: #faf7f0;
}
.gablvm-footer__copyright {
  margin: 1.5rem 0 0;
  padding-top: 1rem;
  border-top: 1px solid rgba(166, 124, 43, 0.35);
  color: #e5c178;
}
</style>
