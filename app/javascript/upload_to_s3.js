document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("upload-form");
  const fileInput = document.getElementById("video-file");
  const statusDiv = document.getElementById("upload-status");
  if (!form || !fileInput) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault(); // ← Railsに送らない！

    const file = fileInput.files[0];
    if (!file) {
      alert("動画ファイルを選んでください");
      return;
    }

    statusDiv.innerText = "アップロード準備中...";

    // ① RailsにプリサインドURLをもらう
    const res = await fetch("/api/uploads/presigned_post", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        file_name: file.name,
        content_type: file.type
      }),
      credentials: "same-origin",
    });

    const { url, fields, key } = await res.json();

    // ② S3 に直接アップロードする
    const formData = new FormData();
    Object.entries(fields).forEach(([k, v]) => formData.append(k, v));
    formData.append("file", file);

    statusDiv.innerText = "S3 にアップロード中...";

    const s3Res = await fetch(url, {
      method: "POST",
      body: formData,
    });

    if (s3Res.status !== 201) {
      statusDiv.innerText = "アップロード失敗";
      return;
    }

    statusDiv.innerText = "アップロード完了！データ登録中...";

    // ③ Railsに「アップロード完了したよ！」と知らせる
    const saveRes = await fetch("/videos", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        video: {
          title: form.querySelector('[name="video[title]"]').value,
          source_key: key,
          status: "uploaded"
        }
      }),
    });

    if (saveRes.ok) {
      statusDiv.innerText = "保存完了！";
      alert("動画をアップロードしました！");
      window.location.href = "/videos"; // 一覧へリダイレクト
    } else {
      statusDiv.innerText = "DB保存に失敗しました";
    }
  });
});
